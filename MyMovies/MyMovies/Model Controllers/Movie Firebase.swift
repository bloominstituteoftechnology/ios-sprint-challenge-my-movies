//
//  Movie Firebase.swift
//  MyMovies
//
//  Created by Ilgar Ilyasov on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension MovieController {
    
    // MARK: - PUT to Firebase
    
    func putMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        guard let id = movie.identifier else { completion(NSError()); return }
        
        let url = baseURL2.appendingPathComponent(id).appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put.rawValue
        
        do {
            let movieData = try JSONEncoder().encode(movie)
            request.httpBody = movieData
            completion(nil)
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error puttind movie to the server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    // MARK: - DELETE from Firebase
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }){
        guard let id = movie.identifier else {completion(NSError()); return }
        
        let url = baseURL2.appendingPathComponent(id).appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting data: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
}
