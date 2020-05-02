//
//  MovieFirebaseController.swift
//  MyMovies
//
//  Created by Claudia Contreras on 5/1/20.
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

class MovieFirebaseController {
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    let baseURL = URL(string: "https://movieapp-40197.firebaseio.com/")!
    
    // MARK: CRUD Functions
    func addMovie(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let identifier = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        guard let movieRepresentation = movie.movieRepresentation else {
            completion(.failure(.noRep))
            return
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            NSLog("Error encoding task \(movie): \(error)")
            completion(.failure(.noEncode))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting task to server: \(error)")
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
}
