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
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
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
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    private let fireBaseUrl = URL(string: "https://movie-cf0d6.firebaseio.com/")!
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    func sendMovieToServer(movie: Movie, completion: @escaping CompletionHandler) {
        
        guard let identifier = movie.identifier?.uuidString else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = fireBaseUrl.appendingPathComponent(identifier).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        // Turn the task into a task representation, then TR into JSon.
        
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
                NSLog("Error putting task to server: \(error)")
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
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        guard let identifier = movie.identifier?.uuidString else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = fireBaseUrl.appendingPathComponent(identifier).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        // Turn the task into a task representation, then TR into JSon.
        
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
                NSLog("Error putting tassk to server: \(error)")
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
    
    func fetchMovieFromServer(completion: @escaping CompletionHandler = { _ in }) {
        
         let requestURL = fireBaseUrl.appendingPathExtension("json")
            
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
                
                // Pull the JSON out of the data, and turn it into [TaskRepresentation]
                do {
                    let movieRepresentations = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({ $0.value })
                    
                    // Figure out which task representations don't exist in Core Data, so we can add them, and figure out which ones have changed
                    try self.updateMovies(with: movieRepresentations)
                    
                    DispatchQueue.main.async {
                        completion(.success(true))
                    }
                } catch {
                    NSLog("Error decoding task representations: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(.noDecode))
                    }
                }
            }.resume()
        }
    
    func updateMovies(with representations: [MovieRepresentation]) throws {
        
        let identifiersToFetch = representations.compactMap({ UUID(uuidString: $0.identifier!.uuidString) })
        
        let representationsByID = Dictionary(uniqueKeysWithValues:
            zip(identifiersToFetch, representations)
        )
        
        // Make a copy of the representations by ID for later use
        var moviesToCreate = representationsByID
        
        // Ask CoreData to find any tasks with these identifiers
        // if identifiersToFetch.contains(someTaskincoreData)
        let predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = predicate
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            
            do {
                // This will only fetch request that match the criteria in our predicate
                let existingMovies = try context.fetch(fetchRequest)
                
                // Lets update the tasks that already exist in Core Data
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else { continue }
                    
                    //                entry.title = representation.title
                    //                entry.bodyText = representation.bodyText
                    //                entry.complete = representation.complete
                    //                entry.priority = representation.priority
                    
                    // If we updated the task, tht means we dont need to make a copy of it, it already exists in Core Data, so remove it from te task we still need to create.
                    moviesToCreate.removeValue(forKey: id)
                }
                
                // Add the tasks that dont exist
                for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
                
            } catch {
                NSLog("Error fetching tasks for UUID: \(error)")
            }
        }
        
        try CoreDataStack.shared.saveContext(context: context)
    }
}
    
