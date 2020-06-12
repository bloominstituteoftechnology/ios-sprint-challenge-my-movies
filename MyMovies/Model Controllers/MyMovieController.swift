//
//  MyMovieController.swift
//  MyMovies
//
//  Created by Morgan Smith on 6/11/20.
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

let baseURL = URL(string: "https://mymovie-66e9f.firebaseio.com/")!

class MyMovieController {
    
     typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
     init() {
            fetchMovieFromServer()
        }
    
        func fetchMovieFromServer(completion: @escaping CompletionHandler = { _ in }) {
            let requestURL = baseURL.appendingPathExtension("json")
            
            URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
                if let error = error {
                    print("Error fetching tasks: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(.otherError))
                    }
                    return
                }
                
                
                guard let data = data else {
                    print("No data returned by data movie")
                    DispatchQueue.main.async {
                        completion(.failure(.noData))
                    }
                    return
                }
                
                do {
                    let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                    
                    try self.updateMovies(with: movieRepresentations)
                    DispatchQueue.main.async {
                        completion(.success(true))
                    }
                } catch {
                    print("Error decoding movie representations: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(.noDecode))
                    }
                    return
                }
            }.resume()
        }
 
        func sendMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
            
            guard let uuid = movie.identifier else {
                completion(.failure(.noIdentifier))
                return
            }
        
            let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
            
            var request = URLRequest(url: requestURL)
            request.httpMethod = "PUT"
            
            do {
                guard let representation = movie.movieRepresentation else {
                    completion(.failure(.noRep))
                    return
                }
                request.httpBody = try JSONEncoder().encode(representation)
            } catch {
                print("Error encoding movie \(movie): \(error)")
                completion(.failure(.noEncode))
                return
            }
            
            URLSession.shared.dataTask(with: request) { (data, _, error) in
                if let error = error {
                    print("Error PUTting movie to server: \(error)")
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
 
        private func updateMovies(with representations: [MovieRepresentation]) throws {
            let context = CoreDataStack.shared.container.newBackgroundContext()
            // Array of UUIDs
            let identifiersToFetch = representations.map { $0.identifier }
            
            let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
            var moviesToCreate = representationsByID
            
            let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
            context.perform {
                do {
                    let existingMovies = try context.fetch(fetchRequest)
            
                    for movie in existingMovies {
                        guard let id = movie.identifier,
                            let representation = representationsByID[id] else { continue }
                        self.update(movie: movie, with: representation)
                        moviesToCreate.removeValue(forKey: id)
                    }
                 
                    for representation in moviesToCreate.values {
                        Movie(movieRepresentation: representation, context: context)
                    }
                } catch {
                    print("error fetching movies for UUIDs: \(error)")
                }
                do {
                    
                    try CoreDataStack.shared.save(context: context)
                } catch {
                    print("error saving)")
                }
            }
            
        }
        
        private func update(movie: Movie, with representation: MovieRepresentation) {
            movie.title = representation.title
            movie.hasWatched = representation.hasWatched ?? false
        }
        
        
        func deleteMovieFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
            guard let uuid = movie.identifier else {
                completion(.failure(.noIdentifier))
                return
            }
            
            let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
            var request = URLRequest(url: requestURL)
            request.httpMethod = "DELETE"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                print(response!)
                completion(.success(true))
            }.resume()
        }
    }

    

