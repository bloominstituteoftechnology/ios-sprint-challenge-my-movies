//
//  FirebaseClient.swift
//  MyMovies
//
//  Created by Shawn Gee on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FirebaseClient {
    
    typealias ErrorCompletion = (Error?) -> Void
    typealias ResultCompletion = (Result<MovieRepsByID, Error>) -> Void
    
    private let baseURL = URL(string: "https://mymovies-shawngee.firebaseio.com/")!
    
    func fetchMoviesFromServer(completion: @escaping ResultCompletion) {
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let error = error {
                NSLog("Error fetching movies \(error)")
                completion(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
                !(200...299).contains(response.statusCode) {
                NSLog("Invalid Response: \(response)")
                completion(.failure(NSError(domain: "Invalid Response", code: response.statusCode)))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned")
                completion(.failure(NSError(domain: "No data to decode", code: 1)))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let movieRepresentations = try decoder.decode(MovieRepsByID.self, from: data)
                completion(.success(movieRepresentations))
            } catch {
                NSLog("Couldn't update entries \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func sendMovieToServer(_ movie: Movie, completion: @escaping ErrorCompletion = { _ in }) {
        let uuid = movie.identifier
        let requestURL = baseURL.appendingPathComponent(uuid).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movie.representation)
        } catch {
            NSLog("Error encoding JSON representation of movie: \(error)")
            completion(error)
            return
        }

        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let error = error {
                NSLog("Error PUTing movie to server: \(error)")
                completion(error)
                return
            }
            
            if let response = response as? HTTPURLResponse,
                !(200...299).contains(response.statusCode) {
                NSLog("Invalid Response: \(response)")
                completion(NSError(domain: "Invalid Response", code: response.statusCode))
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    func deleteMovieWithID(_ uuidString: String, completion: @escaping ErrorCompletion = { _ in }) {
        let requestURL = baseURL.appendingPathComponent(uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let error = error {
                NSLog("Error deleting movie from server: \(error)")
                completion(error)
                return
            }
            
            if let response = response as? HTTPURLResponse,
                !(200...299).contains(response.statusCode) {
                NSLog("Invalid Response: \(response)")
                completion(NSError(domain: "Invalid Response", code: response.statusCode))
                return
            }

            completion(nil)
        }.resume()
    }
}
