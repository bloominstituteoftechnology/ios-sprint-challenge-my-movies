//
//  FirebaseController.swift
//  MyMovies
//
//  Created by Jon Bash on 2019-11-15.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

typealias CompletionHandler = (Error?) -> Void

class FirebaseController {
    // MARK: - URLRequest Generators
    
    private let baseURL: URL = URL(string: "https://lambda-ios-mymovies.firebaseio.com/")!
    
    private func urlRequest(for id: String?) -> URLRequest {
        if let id = id {
            return URLRequest(url:
                baseURL.appendingPathComponent(id)
                .appendingPathExtension(.json)
            )
        }
        return URLRequest(url: baseURL.appendingPathExtension(.json))
    }
    
    private func urlRequest() -> URLRequest {
        return urlRequest(for: nil)
    }
    
    // MARK: - Fetch
    
    // TODO: implement `Result` type in closure
    func fetchMoviesFromServer(completion: @escaping (Error?, [MovieRepresentation]?) -> Void = { _,_ in }) {
        let request = urlRequest()
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching entries: \(error)")
                completion(error, nil)
                return
            }
            guard let data = data else {
                print("No data returned by data task!")
                completion(nil, nil)
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode(
                    [String : MovieRepresentation].self,
                    from: data
                ).values)
                completion(nil, movieRepresentations) // update local movies from server
            } catch {
                print("Error decoding movie representations: \(error)")
                completion(error, nil)
                return
            }
        }.resume()
    }
    
    // MARK: - Send
    
    func sendToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let id = movie.identifier else {
            print("Error: cannot send movie to server; identifier missing!")
            return
        }
        var request = urlRequest(for: id.uuidString)
        request.httpMethod = HTTPMethod.put
        
        do {
            guard let representation = movie.movieRepresentation else {
                print("Error: failed to get movie representation.")
                completion(nil)
                return
            }
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error sending movie to Firebase: \(error)")
            }
            completion(error)
        }.resume()
    }
    
    // MARK: - Delete
    
    func deleteMovieFromFirebase(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let id = movie.identifier else {
            print("Error: cannot delete movie from server; movie has no identifier!")
            completion(nil)
            return
        }
        var request = urlRequest(for: id.uuidString)
        request.httpMethod = HTTPMethod.delete
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error deleting movie from server: \(error)")
            }
            completion(error)
        }.resume()
    }
}
