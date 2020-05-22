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
    case noID
    case otherError
    case noData
    case failedDecode
    case failedEncode
    case badResponse
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class MovieController {
    //MARK: - Enums & Type Aliases -
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    
    // MARK: - Properties
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    var searchedMovies: [MovieDBMovie] = []
    
    private let firebaseURL = URL(string: "https://mymovies-c63cc.firebaseio.com/")!
    
    // MARK: - TheMovieDB API
    func searchForMovie(with searchTerm: String, completion: @escaping CompletionHandler) {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(.failure(.otherError))
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error searching for movie with search term \(searchTerm): \(error)")
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(.failure(.noData))
                return
            }
            
            do {
                let movieDBMovies = try JSONDecoder().decode(MovieDBResults.self, from: data).results
                self.searchedMovies = movieDBMovies
                completion(.success(true))
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(.failure(.failedDecode))
            }
        }.resume()
    }
    
    
    //MARK: - CRUD Methods -
    func fetchMyMovies(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = firebaseURL.appendingPathComponent("json")
        
        URLSession.shared.dataTask(with: requestURL) { data, _, error in
            if let error = error {
                NSLog("Error fetching movies from server: \(error) \(error.localizedDescription)")
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                NSLog("Error: No data returned from firebase fetch.")
                completion(.failure(.noData))
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                self.updateMovies(with: movieRepresentations)
                completion(.success(true))
            } catch {
                NSLog("Error decoding tasks from firebase: \(error) \(error.localizedDescription)")
                completion(.failure(.failedDecode))
                return
            }
        }.resume()
    }
    
    func sendMoviesToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let identifier = movie.identifier else {
            NSLog("Error: Movie object has no identifier.")
            completion(.failure(.noID))
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        do {
            guard let representation = movie.representation else {
                NSLog("Error: Movie object has no vaild representation to encode.")
                completion(.failure(.failedEncode))
                return
            }
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding movie data: \(error) \(error.localizedDescription)")
            completion(.failure(.failedEncode))
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                NSLog("Error sending your request: \(error) \(error.localizedDescription)")
                completion(.failure(.otherError))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                    NSLog("Error sending your request: Bad response from firebase.")
                    completion(.failure(.badResponse))
                    return
            }
            
            completion(.success(true))
        }.resume()
    }
    
    func updateMovies(with representations: [MovieRepresentation]) {
        let identifiersToFetch = representations.compactMap { UUID(uuidString: $0.identifier) }
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var moviesToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            do {
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let identifier = movie.identifier,
                        let representation = representationsByID[identifier] else { return }
                    
                    self.update(for: movie, with: representation)
                    moviesToCreate.removeValue(forKey: identifier)
                }
            } catch {
                NSLog("Error updating during fetch: \(error) \(error.localizedDescription)")
                return
            }
            for representation in moviesToCreate.values {
                Movie(representation: representation, context: context)
            }
        }
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error saving updates: \(error) \(error.localizedDescription)")
            return
        }
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let identifier = movie.identifier else {
            NSLog("Unable to delete movie from server: Movie has no identifier.")
            completion(.failure(.noID))
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                NSLog("Error processing delete request: \(error) \(error.localizedDescription)")
                completion(.failure(.otherError))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                    NSLog("Error: bad response from friebase when deleting object.")
                    completion(.failure(.badResponse))
                    return
            }
            completion(.success(true))
        }.resume()
    }
    
    
    //MARK: - Helper Methods -
    private func update(for movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched
    }
    
    
}
