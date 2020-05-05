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
    
    var movieList: [Movie] = []
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let fireBaseURL = URL(string: "https://my-moviespt5.firebaseio.com/")!
    
    
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
    
    func sendToFirebase(movie: Movie, completion: @escaping CompletionHandler) {
  
        guard let identifier = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = fireBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard let movieRepresentation = movie.movieRepresentation else {
                completion(.failure(.noRep))
                return
            }
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            NSLog("Error encoding task \(movie): \(error)")
            completion(.failure(.noEncode))
            return
        }
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTing task to server: \(error)")
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
    
    func deleteTaskFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        // Make the URL by adding the task's identifier to the base URL, and add the .json
        guard let identifier = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = fireBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                // Something went wrong
                NSLog("Error: Status code is not the expected 200. Instead it is \(response.statusCode)")
            }
            
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
    
    func updateMovies(with representaions: [MovieRepresentation]) throws {
        
        let identifiersToFetch = representaions.compactMap({ UUID(uuidString: $0.identifier!) })
        
        let representaionsById = Dictionary(uniqueKeysWithValues:
            zip(identifiersToFetch, representaions)
        )
        
        var moviesToCreate = representaionsById
        
        let predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = predicate
        
        // Create a new background context. The thread that this context is created on is completely random; you have no control over it
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        // I want to make sure I'm using this context on the right thread, so I will call .perform
        
        context.performAndWait {
            do {
                // This will only fetch the movies that match the criteria in our predicate
                let existingMovies = try context.fetch(fetchRequest)
                
                // Let's update the movies that already exist in Core Data
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representaionsById[id] else { continue }
                    
                    movie.title = representation.title
                    movie.hasWatched = representation.hasWatched!
                    movie.priority = representation.priority
                 
                    // If we updated the movie, that means we don't need to make a copy of it. It already ecists in Core Data, so remove it from the movies we still need to create
                    moviesToCreate.removeValue(forKey: id)
                }
                
                // Add the tasks that don't exist
                for representaion in moviesToCreate.values {
                        Movie(movieRepresentation: representaion, context: context)
                }
                
            } catch {
                NSLog("Error fetching tasks for UUID: \(error)")
            }
        }
        // This will save the correct context (background context)
        try CoreDataStack.shared.save(context: context)
    }
    
    func fetchTasksFromServer(completion: @escaping CompletionHandler = { _ in }) {
        
        let requestURL = fireBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, err) in
            if let error = err {
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
            
            // Pull the JSON out of the data, and turn it into [MovieRepresentaion]
            do {
                let movieRepresentations = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({ $0.value })
                // Figure out which task representaion doesn't exist in Core Data, so we can add them, and figure out which ones have changed
                try self.updateMovies(with: movieRepresentations)
            } catch {
                
            }
        }.resume()
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
