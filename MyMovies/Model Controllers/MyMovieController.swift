//
//  MyMovieController.swift
//  MyMovies
//
//  Created by Wyatt Harrell on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MyMovieController {
    
    typealias CompletionHandler = (Error?) -> Void
    let baseURL = URL(string: "https://movies-c9611.firebaseio.com/")!
    
    init() {
        fetchMoviesFromServer()
    }
    
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
            
            try CoreDataStack.shared.save()
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
    
    
    // MARK: - Private Methods
    
    private func updateMovies(with representations: [MovieRepresentation]) throws {
        let tasksByID = representations.filter { $0.identifier != nil }
        let identifiersToFetch = tasksByID.compactMap { $0.identifier }
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, tasksByID))
        var moivesToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            do {
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else { continue }
                    self.update(movie: movie, with: representation)
                    moivesToCreate.removeValue(forKey: id)
                }
                
                for representation in moivesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
                
                //try CoreDataStack.shared.mainContext.save()
            } catch {
                NSLog("Error fetching tasks for UUIDs: \(error)")
            }
        }
        
        try CoreDataStack.shared.save(context: context)
        
    }
    
    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.identifier = representation.identifier
        movie.hasWatched = representation.hasWatched ?? false
    }
}
