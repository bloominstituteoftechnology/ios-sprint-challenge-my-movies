//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//
// ChrisPrice

import Foundation
import CoreData

enum NetworkError: Error {
    case noIdentifier
    case otherError
    case noData
    case noDecode
    case noEncode
    case noRep
}

class MovieController {
    
    // MARK: - Properties
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://mymovies-79a4a.firebaseio.com/")!
    
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(NSError())
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error searching for movie with search term \(searchTerm): \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = try JSONDecoder().decode(MovieRepresentations.self, from: data).results
                self.searchedMovies = movieRepresentations
                completion(nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let identifier = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard let representation = movie
                .movieRepresentation else {
                    completion(.failure(.noRep))
                    return
            }
            
            request.httpBody = try JSONEncoder().encode(representation)
            } catch {
                NSLog("Error encoding movie \(movie): \(error)")
                completion(.failure(.noEncode))
                return
            }
            
            URLSession.shared.dataTask(with: request) { (data, _, error) in
                if let error = error {
                    NSLog("Error PUTting task to server: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(.otherError))
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            }.resume()
        }
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching tasks: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.otherError))
                }
                return
            }
            
            guard let data = data else {
                NSLog("Error: No data returned from data task")
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            do {
                let movieRepresentations = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({ $0.value })
                
                try self.updateMovies(with: movieRepresentations)
                
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } catch {
                NSLog("Error decoding movie representations: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.noDecode))
                }
            }
        }.resume()
    }
    
    func updateMovies(with representations: [MovieRepresentation]) throws {
        
        let identifiersToFetch = representations.compactMap({ UUID(uuidString: $0.identifier!) })
        
        let representationsByID = Dictionary(uniqueKeysWithValues:
            zip(identifiersToFetch, representations)
        )
        
        var moviesToCreate = representationsByID

        let predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = predicate
        
        // Create a new background context. The thread that this context is created on is completely random; you have no control over it.
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        
        // I want to make sure I'm using this context on the right thread, so I will call .perform
        
        context.performAndWait {
            do {
                
                // This will only fetch the tasks that match the criteria in our predicate
                let existingTasks = try context.fetch(fetchRequest)
                
                // Let's update the tasks that already exist in Core Data
                
                for task in existingTasks {
                    guard let id = task.identifier,
                        let representation = representationsByID[id] else { continue }
                    
                    task.name = representation.name
                    task.notes = representation.notes
                    task.complete = representation.complete
                    task.priority = representation.priority
                    
                    // If we updated the task, that means we don't need to make a copy of it. It already exists in Core Data, so remove it from the tasks we still need to create
                    tasksToCreate.removeValue(forKey: id)
                }
                
                // Add the tasks that don't exist
                for representation in tasksToCreate.values {
                    Task(taskRepresentation: representation, context: context)
                }
                
            } catch {
                NSLog("Error fetching tasks for UUIDs: \(error)")
            }
        }
        // This will save the correct context (background context)
        try CoreDataStack.shared.save(context: context)
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let identifier = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting task for id \(identifier.uuidString): \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.otherError))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(true))
            }
        }.resume()
    }
    
    func updateWatched(movie: Movie) {
            movie.hasWatched.toggle()
            put(movie: movie)
    }
}
