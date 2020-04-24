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

let firebaseURL = URL(string: "https://movie-a4d2b.firebaseio.com/")!

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
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    init() {
        fetchMoviesFromServer()
    }
    
     func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
          let requestURL = firebaseURL.appendingPathExtension("json")

        URLSession.shared.dataTask(with: requestURL) { data, response, error in
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion(.failure(.otherError))
                return
            }

            guard let data = data else {
                NSLog("No data returned from fetch")
                completion(.failure(.noData))
                return
            }

            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)  // converts a dictionary to an array
                try self.updateMovies(with: movieRepresentations)
                completion(.success(true))
            } catch {
                NSLog("Error decoding tasks from server: \(error)")
                completion(.failure(.noDecode))
            }
        }.resume()
    }
    
    func sendMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in}) {
            
        guard let uuid = movie.identifier else {
            completion(.failure(.noIdentifier))
            print("failed")
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard let representation = movie.movieRepresentation else {
                completion(.failure(.noRep))
                return
            }
            request.httpBody  = try JSONEncoder().encode(representation)
        } catch {
            NSLog("error encoding movie \(movie): \(error)")
            completion(.failure(.noEncode))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("error sending movie to server: \(error)")
                completion(.failure(.otherError))
                return
            }
            print("success")
            completion(.success(true))
        }.resume()
    }

    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }

        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("error deleting task from server: \(error)")
                completion(.failure(.otherError))
                return

            }

            completion(.success(true))
        }.resume()
    }

    private func updateMovies(with representations: [MovieRepresentation]) throws {
        
        let identifiersToFetch = representations.compactMap { UUID(uuidString: $0.identifier!)}

        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var moviesToCreate = representationsByID
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)

        let context = CoreDataStack.shared.container.newBackgroundContext()

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
                try context.save()
            } catch {
                NSLog("error fetching movies with UUIDs: \(identifiersToFetch), with error: \(error)")
            }
        }
    }

    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched  = representation.hasWatched ?? false
        
    }
    
}
