//
//  MovieController.swift
//  MyMovies
//
//  Created by Chad Parker on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
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
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    let baseURL = URL(string: "https://lambda-mymovies.firebaseio.com/")!
    
    func put(movie: Movie, completion: @escaping CompletionHandler) {
        // Check to make sure an id exists, otherwise we can't PUT the Movie to a unique place in Firebase
        guard let identifier = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        // Turn the Movie into a MovieRepresentation, then TR into JSON
        do {
            guard let movieRepresentation = movie.movieRepresentation else {
                completion(.failure(.noRep))
                return
            }
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            NSLog("Error encoding movie \(movie): \(error)")
            completion(.failure(.noEncode))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil else {
                NSLog("Error PUTing movie to server: \(error!)")
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
        
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { data, _, error in
            guard error == nil else {
                NSLog("Error fetching movies: \(error!)")
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
            
            // Pull the JSON out of the data, and turn it into [MovieRepresentation]
            do {
                let movieRepresentations = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map { $0.value }
                
                // Figure out which movie representations don't exist in Core Data, so we can add them, and figure out which ones have changed
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
        
        let identifiersToFetch = representations.compactMap { UUID(uuidString: $0.identifier) }
        
        let representationsByID = Dictionary(uniqueKeysWithValues:
            zip(identifiersToFetch, representations)
        )
        
        // Make a copy of the representationsByID for later use
        var moviesToCreate = representationsByID
        
        // Ask Core Data to find any movies with these identifiers
        let predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = predicate
        
        //let context = CoreDataStack.shared.mainContext
        
        // create a new background context. thread is completely random, you have no control over it.
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        // make sure using context on the right thread
        context.performAndWait {
            do {
                // this will only fetch the movies that match the criteria in predicate
                let existingMovies = try context.fetch(fetchRequest)
                
                // update the movies that already exist in Core Data
                for movie in existingMovies {
                    guard
                        let id = movie.identifier,
                        let representation = representationsByID[id],
                        let identifier = UUID(uuidString: representation.identifier) else { continue }
                    
                    movie.identifier = identifier
                    movie.title = representation.title
                    movie.hasWatched = representation.hasWatched
                    
                    // if we updated the movie, already exists in Core Data, don't need to create it
                    moviesToCreate.removeValue(forKey: id)
                }
                
                // add the movies that don't exist
                for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
                
            } catch {
                NSLog("Error fetching movies for UUIDs: \(error)")
            }
        }
        
        // this will save the correct context (background context)
        try CoreDataStack.shared.save(context: context)
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        // make the URL by adding movie's identifier & .json
        guard let identifier = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            guard error == nil else {
                NSLog("Error deleting movie for id \(identifier.uuidString): \(error!)")
                DispatchQueue.main.async {
                    completion(.failure(.otherError))
                }
                return
            }
            if let response = response as? HTTPURLResponse,
                !(200...299).contains(response.statusCode) {
                NSLog("Error: Status code is \(response.statusCode)")
            }
            
            DispatchQueue.main.async {
                completion(.success(true))
            }
        }.resume()
    }
}
