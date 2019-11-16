//
//  MyMoviesController.swift
//  MyMovies
//
//  Created by BDawg on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

        let dbURL = URL(string: "https://movie-list-for-ios.firebaseio.com/")!

class MyMoviesController {

        typealias CompletionHandler = (Error?) -> Void
    
    init() {
        fetchMoviesFromServer()
    }
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = dbURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { data, _, error in
            if let error = error {
                print("Error fetching tasks: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                print("No data returned by data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                try self.updateMovies(with: movieRepresentations)
                completion(nil)
            } catch {
                print("Error decoding task representations: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    func sendMovieToServer(movie: Movie, completion: @escaping () -> Void = { }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = dbURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var representation = movie.movieRepresentation else {
                completion()
                return
            }

            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding task: \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            completion()
            
            if let error = error {
                print("Error PUTing task to server: \(error)")
            }
        }.resume()
    }
    
    func deleteTask(_ movie: Movie, completion: @escaping (CompletionHandler) = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        
        let context = CoreDataStack.shared.mainContext
        
        do {
            context.delete(movie)
            try CoreDataStack.shared.save(context: context)
        } catch {
            context.reset()
            print("Error deleting object from managed object context: \(error)")
        }
        
        let requestURL = dbURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print(response!)
            completion(error)
        }.resume()
    }
    
    // MARK: - Private Methods
    
    private func updateMovies(with representations: [MovieRepresentation]) throws {
        let moviesWithID = representations.filter { $0.identifier != nil }
        let identifiersToFetch = moviesWithID.compactMap { $0.identifier! }
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
        
        var moviesToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
            do {
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else { continue }
                    
                    self.update(movie: movie, with: representation)
                    moviesToCreate.removeValue(forKey: id)
                }
                
                for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation)
                }
            } catch {
                print("Error fetching tasks for UUIDs: \(error)")
            }
        
        try CoreDataStack.shared.save(context: context)
    }
    
    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title

    }
    
}
