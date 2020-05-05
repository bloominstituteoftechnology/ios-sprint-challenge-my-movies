//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

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
    
    //MARK: - Properties -
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let fireBaseURL = URL(string: "https://movie-a0439.firebaseio.com/")!
    var searchedMovies: [MovieRepresentation] = []
    
    //MARK: - Methods -
    
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
    
    func sendMovieToServer( _ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        guard let id = movie.identifier?.uuidString else {
            completion(.failure(.noIdentifier))
            return
        }
        
        guard let movieRep = movie.movieRepresentation else {
            completion(.failure(.noRep))
            return
        }
        
        let requestURL = fireBaseURL.appendingPathComponent(id).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRep)
        } catch {
            NSLog("Could not encode the movie's representation: \(error)")
            completion(.failure(.noEncode))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            
            if let error = error {
                DispatchQueue.main.async {
                    NSLog("Could not send movie to server: \(error)")
                    completion(.failure(.otherError))
                    return
                }
            }
            
            DispatchQueue.main.async {
                completion(.success(true))
            }
            
        }.resume()
        
    }
    
    func fetchTasksFromServer(completion: @escaping CompletionHandler = { _ in }) {
        
        let requestURL = fireBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching movies: \(error)")
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
            
            // Pull the JSON out of the data, and turn it into [TaskRepresentation]
            do {
                let movieRepresentation = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({ $0.value })
                
                // Figure out which task representations don't exist in Core Data, so we can add them, and figure out which ones have changed
                try self.updateMovies(with: movieRepresentation)
                
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
        
        let identifiersToFetch = representations.compactMap({ $0.identifier })
        
        let representationsByID = Dictionary(uniqueKeysWithValues:
            zip(identifiersToFetch, representations)
        )
        
        // Make a copy of the representationsByID for later use
        var moviesToCreate = representationsByID
        
        // Ask Core Data to find any tasks with these identifiers
        
        // if identifiersToFetch.contains(someTaskInCoreData)
        let predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = predicate
        
        // Create a new background context. The thread that this context is created on is completely random; you have no control over it.
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        
        // I want to make sure I'm using this context on the right thread, so I will call .perform
        
        context.performAndWait {
            
            do {
                
                // This will only fetch the tasks that match the criteria in our predicate
                let existingMovies = try context.fetch(fetchRequest)
                
                // Let's update the tasks that already exist in Core Data
                
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else { continue }
                    
                    movie.title = representation.title
                    movie.hasWatched = representation.hasWatched!
                    movie.identifier = id
                    
                    // If we updated the task, that means we don't need to make a copy of it. It already exists in Core Data, so remove it from the tasks we still need to create
                    moviesToCreate.removeValue(forKey: id)
                }
                
                // Add the tasks that don't exist
                for representation in moviesToCreate.values {
                    Movie(representation, context)
                }
                
            } catch {
                NSLog("Error fetching movies for UUIDs: \(error)")
            }
        }
        // This will save the correct context (background context)
        try CoreDataStack.shared.save(context: context)
    }
    
    func deleteFromServer( _ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        guard let id = movie.identifier?.uuidString else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = fireBaseURL.appendingPathComponent(id).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            
            if let error = error {
                DispatchQueue.main.async {
                    NSLog("Could not delete entry from server: \(error)")
                    completion(.failure(.otherError))
                    return
                }
            }
            
            DispatchQueue.main.async {
                completion(.success(true))
            }
            
        }.resume()
        
    }
    
    func save(context: NSManagedObjectContext) {
        
        context.performAndWait {
            do {
                try context.save()
            } catch {
                NSLog("Could not save to context \(context): \(error)")
            }
        }
        
    }
    
} //End of class

