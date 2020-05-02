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
    case noRep
    case noIdentifier
    case otherError
    case noData
    case noDecode
    case noEncode
}

enum HTTPMethod: String {
    case put = "PUT"
    case delete = "DELETE"
}

let fireBaseURL: URL = URL(string: "https://movies-1c777.firebaseio.com/")!

class MovieController {
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    init() {
        fetchEntriesFromServer()
    }
    
    func fetchEntriesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = fireBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { data, response, error in
            if let error = error {
                NSLog("Failed fetch with error: \(error)")
                return completion(.failure(.otherError))
            }
            guard let data = data else {
                NSLog("Fetch returned with no data.")
                return completion(.failure(.noData))
            }
            
            do {
                let movieRepresentation = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                self.updateMovies(with: movieRepresentation)
                completion(.success(true))
            } catch {
                NSLog("Failed to decode data from server with error: \(error)")
                completion(.failure(.noDecode))
            }
        }
        .resume()
    }
    
    func sendMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            NSLog("Movie \(movie) had no identifier.")
            return completion(.failure(.noIdentifier))
        }
        
        var request = newRequest(uuid: uuid, method: .put)
        do {
            guard let representation = movie.movieRepresentation else {
                NSLog("Unable to get rep from movie \(movie)")
                return completion(.failure(.noRep))
            }
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Failed to encode entry \(movie): \(error)")
            return completion(.failure(.noEncode))
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("Session returned with error: \(error)")
                return completion(.failure(.otherError))
            }
            
            completion(.success(true))
        }
        .resume()
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            NSLog("Movie \(movie) had no identifier.")
            return completion(.failure(.noIdentifier))
        }
        
        let request = newRequest(uuid: uuid, method: .delete)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("Session return with error: \(error)")
                return completion(.failure(.otherError))
            }
            
            completion(.success(true))
        }
        .resume()
    }
    
    private func newRequest(uuid: UUID, method: HTTPMethod) -> URLRequest {
        let requestURL = fireBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        return request
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

    private func updateMovies(with representations: [MovieRepresentation]) {
        let idsToFetch = representations.compactMap { $0.identifier }
        let representationsById = Dictionary(uniqueKeysWithValues: zip(idsToFetch, representations))
        var tasksToCreate = representationsById
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", idsToFetch)
        
        let ctx = CoreDataStack.shared.container.newBackgroundContext()
        
        ctx.perform {
            do {
                let existingMovies = try ctx.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsById[id] else { continue }
                    
                    self.update(movie: movie, movieRepresentation: representation)
                    tasksToCreate.removeValue(forKey: id)
                }
                
                for representation in tasksToCreate.values {
                    Movie(movieRepresentation: representation, context: ctx)
                }
                
                try ctx.save()
            } catch {
                NSLog("Failed to fetch entries \(idsToFetch) with error: \(error)")
                return
            }
        }
    }
    
    private func update(movie: Movie, movieRepresentation: MovieRepresentation) {
        movie.title = movieRepresentation.title
        movie.identifier = movieRepresentation.identifier
        movie.hasWatched = movieRepresentation.hasWatched!
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
