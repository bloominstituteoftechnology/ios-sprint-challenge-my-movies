//
//  MyMovieController.swift
//  MyMovies
//
//  Created by Wyatt Harrell on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class MyMovieController {
    
    typealias CompletionHandler = (Error?) -> Void
    let baseURL = URL(string: "https://movies-c9611.firebaseio.com/")!
    
//    init() {
//        fetchMoviesFromServer()
//    }
    
    func sendMovieToServer(movie: Movie, completeion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier!
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard let representation = movie.movieRepresentation else {
                completeion(NSError())
                return
            }
            
            try CoreDataStack.shared.mainContext.save()
            #warning("Migrate saving")
            request.httpBody = try JSONEncoder().encode(representation)
            
        } catch {
            NSLog("Error encoding/saving movie: \(error)")
            completeion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTing movie to server: \(error)")
                completeion(error)
                return
            }
            
            completeion(nil)
        }.resume()
    }
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching tasks: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned by data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                try self.updateMovies(with: movieRepresentations)
                completion(nil)
            } catch {
                NSLog("Error decoding or saving data from Firebase: \(error)")
                completion(error)
            }
            
        }.resume()
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier!
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }.resume()
    }
    
    // MARK: - Private Methods
    
    private func updateMovies(with representations: [MovieRepresentation]) throws {
        
    }
    
    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.identifier = representation.identifier
        movie.hasWatched = representation.hasWatched ?? false
    }
}
