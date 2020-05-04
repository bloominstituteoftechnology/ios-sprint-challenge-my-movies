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

