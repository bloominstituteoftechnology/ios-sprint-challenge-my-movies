//
//  MyMoviesController.swift
//  MyMovies
//
//  Created by Joel Groomer on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MyMoviesController {
    let baseURL = URL(string: "https://lambda-my-movies.firebaseio.com/")!
    typealias CompletionHandler = (Error?) -> Void
    
    
    // MARK: - Local Store Methods
    
    func addMovie(representation: MovieRepresentation) {
        guard let movie = Movie(representation: representation) else { return }
        
        put(movie: movie)
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error saving new movie: \(error)")
        }
    }
    
    func toggleSeen(movie: Movie) {
        do {
            movie.hasWatched.toggle()
            try CoreDataStack.shared.save()
        } catch {
            print("Error toggling: \(error)")
        }
        
        put(movie: movie)
        
    }
    
    func toggleSeen(representation: MovieRepresentation) {
        guard let movie = Movie(representation: representation) else { return }
        toggleSeen(movie: movie)
    }
    
    func deleteMovie(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        deleteFromServer(movie: movie) { (error) in
            if let error = error {
                print("Will not delete local copy")
                completion(error)
                return
            } else {
                CoreDataStack.shared.mainContext.delete(movie)
                do {
                    try CoreDataStack.shared.save()
                } catch {
                    print("Error saving after delete: \(error)")
                }
                completion(nil)
            }
        }
    }
    
    func update(movie: Movie, with representation: MovieRepresentation) {
        guard let hasWatched = representation.hasWatched else { return }
        movie.hasWatched = hasWatched
        movie.title = representation.title
    }
    
    func updateMovies(with representations: [MovieRepresentation]) throws {
        // Create a dictionary of Representations keyed by their UUID
          // filter out entries with no UUID
        let moviesWithID = representations.filter({ $0.identifier != nil })
          // create array of just the UUIDs (string form)
        let identifiersToFetch = moviesWithID.compactMap({ $0.identifier })
          // creates the dictionary
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
        
        var moviesToCreate = representationsByID    // all movies for now, will be wittled down later
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            do {
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let id = movie.identifier, let representation = representationsByID[id] else { continue }
                    self.update(movie: movie, with: representation)
                    moviesToCreate.removeValue(forKey: id)
                }
                
                for representation in moviesToCreate.values {
                    let _ = Movie(representation: representation, context: context)
                }
            } catch {
                print("Error fetching tasks for UUIDs: \(error)")
            }
        }
        try CoreDataStack.shared.save(context: context)
    }
    
    
    // MARK: - Server Methods
    
    private func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            // convert managed object into Codable-conforming struct
            guard var representation = movie.representation else {
                completion(nil)
                return
            }
            representation.identifier = uuid
            movie.identifier = uuid
            
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error saving or encoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("Error saving movie to server: \(error)")
                completion(error)
                return
            }
        }.resume()
        completion(nil)
    }
    
    private func deleteFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(nil)
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("Error deleting movie from server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
}
