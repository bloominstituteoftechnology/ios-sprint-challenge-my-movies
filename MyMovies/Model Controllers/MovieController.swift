//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

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
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    private let firebaseURL = URL(string: "https://mymovies-b24be.firebaseio.com/")!
    
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
    
    // MARK: - Firebase
    
    func sendMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            return completion(.failure(.noIdentifier))
        }
        var request = apiHandler(uuid: uuid, method: .put)
        
        do {
            guard let representation = movie.movieRepresentation else {
                return completion(.failure(.noRep))
            }
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Failed to encode movie \(movie) with error: \(error)")
            return completion(.failure(.noEncode))
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
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
        let request = apiHandler(uuid: uuid, method: .delete)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("Failed to delete movie \(movie) from server with error: \(error)")
                return completion(.failure(.otherError))
            }
            
            completion(.success(true))
        }
        .resume()
    }
    
    // MARK: - Helper Method
    
    private func apiHandler(uuid: UUID, method: HTTPMethod) -> URLRequest {
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        return request
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
