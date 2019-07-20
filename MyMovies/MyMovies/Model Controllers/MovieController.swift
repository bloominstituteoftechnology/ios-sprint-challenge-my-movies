//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

enum HTTPMethods: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
}

class MovieController {
    
    // MARK: - FireBase URL
    
    let fireBaseURL = URL(string: "https://mymoviessprintchallenge.firebaseio.com/")!
    
    // MARK: - API
    
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
}

extension MovieController {
    
    
    // MARK: - Firebase
    
    typealias CompletionHandler = (Error?) -> Void
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = fireBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethods.put.rawValue
        
        do {
            guard let representation = movie.movieReprensentation else { // Should it be a `var`?
                completion(NSError())
                return
            }
            //representation.identifier = uuid.uuidString // is this needed?
            movie.identifier = uuid
            // try saveToPersistentStore()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error ecoding movie: \(movie) \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting to the server")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
        
    }
    
    
}
