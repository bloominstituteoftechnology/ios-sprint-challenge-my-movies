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
    case noDecode
    case noEncode
    case noData
    case noIdentifier
    case noRep
    case otherError
}

enum HTTPMethod: String {
    case put = "PUT"
    case delete = "DELETE"
}

class MovieController {
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    var searchedMovies: [MovieRepresentation] = []
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://mymovies-19d0a.firebaseio.com/")!
    
    init() {
        fetchMoviesFromServer()
    }
    
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
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
           let requestURL = firebaseURL.appendingPathExtension("json")

           URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
               if let error = error {
                   NSLog("Failed fetch with error: \(error)")
                   return completion(.failure(.otherError))
               }

               guard let data = data else {
                   NSLog("No data returned from fetch.")
                   return completion(.failure(.noData))
               }

               do {
                   let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                   self.updateMovies(with: movieRepresentations)
                   completion(.success(true))
               } catch {
                   NSLog("Failed to decode movie representations from server.")
                   completion(.failure(.noDecode))
               }
           }
           .resume()
       }
    
    func sendMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            return completion(.failure(.noIdentifier))
        }
        var request = handler(uuid: uuid, method: .put)

        do {
            guard let representation = movie.movieRepresentation else {
                return completion(.failure(.noRep))
            }
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Failed to encode movie \(movie) with error: \(error)")
            return completion(.failure(.noEncode))
        }

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                NSLog("Failed to send movie \(movie) to server with error: \(error)")
                return completion(.failure(.otherError))
            }

            completion(.success(true))
        }
        .resume()
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            return completion(.failure(.noIdentifier))
        }
        let request = handler(uuid: uuid, method: .delete)

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                NSLog("Failed to delete movie \(movie) from server with error: \(error)")
                return completion(.failure(.otherError))
            }

            completion(.success(true))
        }
        .resume()
    }
    
    private func updateMovies(with representations: [MovieRepresentation]){
        let identifiersToFetch = representations.compactMap { $0.identifier }
        let representationsById = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var moviesToCreate = representationsById

        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)

        let context = CoreDataStack.shared.container.newBackgroundContext()

        context.perform {
            do {
                let existingMovies = try context.fetch(fetchRequest)

                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsById[id] else { continue }
                    self.update(movie: movie, with: representation)
                    moviesToCreate.removeValue(forKey: id)
                }

                for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }

                try context.save()
            } catch {
                NSLog("Failed to fetch movies \(identifiersToFetch) with errpr: \(error)")
                return
            }
        }
    }

    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched ?? false
    }
    
    private func handler(uuid: UUID, method: HTTPMethod) -> URLRequest {
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        return request
    }
    
    
}

