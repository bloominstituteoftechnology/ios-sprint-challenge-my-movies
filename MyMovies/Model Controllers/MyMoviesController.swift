//
//  MyMoviesController.swift
//  MyMovies
//
//  Created by BDawg on 11/17/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MyMoviesController {
    
    let dbURL = URL(string: "https://movie-list-for-ios.firebaseio.com/")!
    let context = CoreDataStack.shared.mainContext
    
    typealias CompletionHandler = (Error?) -> Void
    
//    init() {
//        fetchMoviesFromServer()
//    }
//    
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        let requestURL = dbURL.appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                print("No data returned by data movie")
                completion(NSError())
                return
            }
            
            var movieRepresentations: [MovieRepresentation] = []
            do {
                let decodedMovies = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
                movieRepresentations = Array(decodedMovies.values)
                try self.updateMyMovies(with: movieRepresentations)
                completion(nil)
            } catch {
                print("Error decoding movie representation: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    
    func sendMovieToServer(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = dbURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard let representation = movie.representation else {
                completion(NSError())
                return
            }
            
            movie.identifier = uuid
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error putting movie to server \(error)")
                completion(error)
                return
            }
        }.resume()
        completion(nil)
    }
    
    func createMyMovie(title: String) {
        let movie = Movie(title: title)
        
        sendMovieToServer(movie: movie)
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            print("There was an error creating movie object: \(error)")
        }
    }
    
    func updateMyMovie(title: String) {
        let movie = Movie(title: title)
        
        movie.hasWatched = !movie.hasWatched
        
        sendMovieToServer(movie: movie)
        try! CoreDataStack.shared.mainContext.save()
    }
    
    func deleteMyMovie(movie: Movie)  {
        deleteMovieFromServer(movie)
        
        let context = CoreDataStack.shared.mainContext
        
        do {
            context.delete(movie)
            try CoreDataStack.shared.save(context: context)
        } catch {
            context.reset()
            print("There was an error deleting your movie: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        
        guard let identifier = movie.identifier else {
                  NSLog("Entry identifier is nil")
                  completion(NSError())
                  return
              }
              
        let requestURL = dbURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
              var request = URLRequest(url: requestURL)
              request.httpMethod = "DELETE"
              
              URLSession.shared.dataTask(with: request) { (data, _, error) in
                  if let error = error {
                      NSLog("Error deleting entry from server: \(error)")
                      completion(error)
                      return
                  }
                  
                  completion(nil)
                  }.resume()
    }
    
    
    func updateMyMovies(with representations: [MovieRepresentation]) throws {
        let moviesWithID = representations.filter { $0.identifier != nil }
        let identifiersToFetch = representations.map { $0.identifier }
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
        
        var moviesToCreate = representationsByID
        
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
                    moviesToCreate.removeValue(forKey: id)
                }
                
                for representation in moviesToCreate.values {
                    Movie(representation: representation)
                }
            } catch {
                print("Error fetching movies: \(error)")
            }
        }
        
        try CoreDataStack.shared.save(context: context)
    }
    
    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched ?? false
    }
}
