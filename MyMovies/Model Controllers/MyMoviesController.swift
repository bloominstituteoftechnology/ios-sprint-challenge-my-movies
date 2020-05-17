//
//  MyMoviesController.swift
//  MyMovies
//
//  Created by Casualty on 10/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MyMoviesController {
    static let shared = MyMoviesController()
    
    // URL we will send Movie to
    let baseURL = URL(string: "https://thomasallendye.firebaseio.com/")!
    typealias CompletionHandler = (Error?) -> Void
    
    // MARK: - Local Store Methods
    
    func addMovie(representation: MovieRepresentation) {
        guard let movie = Movie(representation: representation) else{
            print("No movie returned")
            return
        }
        
        put(movie: movie)
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error creating new movie \(error)")
        }
    }
    
    // Function to add Movie
    func addMovie(title: String) {
        let movie = Movie(title: title)
        put(movie: movie)
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error creating new movie \(error)")
        }
    }
    
    // Function to toggle if movie has been seen
    func toggleSeen(movie: Movie) {
        do {
            movie.hasWatched.toggle()
            try CoreDataStack.shared.save()
        } catch {
            print("Error swithing watched bool \(error)")
        }
        
        put(movie: movie)
        
    }
    
    // Function to delete movie
    func deleteMovie(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        CoreDataStack.shared.mainContext.delete(movie)
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error updating after deleting \(error)")
            CoreDataStack.shared.mainContext.reset()
        }
        completion(nil)
    }
    
    // Toggle the has been seen
    func toggleHasSeen(representation: MovieRepresentation) {
        guard let movie = Movie(representation: representation) else { return }
        toggleSeen(movie: movie)
    }

    func update(movie: Movie, with representation: MovieRepresentation) {
        guard let hasWatched = representation.hasWatched else { return }
        movie.hasWatched = hasWatched
        movie.title = representation.title
    }
    
    func updateMovies(with representations: [MovieRepresentation]) throws {
        
        let moviesWithID = representations.filter({ $0.identifier != nil })
        let identifiersToFetch = moviesWithID.compactMap({ $0.identifier })
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
        
        var moviesToCreate = representationsByID
        
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
                print("Error fetching UUIDs tasks \(error)")
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
            print("Error saving or encoding movie \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("Error updating movie on server \(error)")
                completion(error)
                return
            }
        }.resume()
        completion(nil)
    }
    
    func deleteFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(nil)
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("Error deleting movie \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func fetchMyMovies(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error fetching movies \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                print("No data")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let dictionaryOfMovies = try decoder.decode([String : MovieRepresentation].self, from: data)
                let movieRepresentations = Array(dictionaryOfMovies.values)
                try self.updateMovies(with: movieRepresentations)
            } catch {
                print("Error decoding representation \(error)")
                completion(error)
                return
            }
        }.resume()
    }
}
