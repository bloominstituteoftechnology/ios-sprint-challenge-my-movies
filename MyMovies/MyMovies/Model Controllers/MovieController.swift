//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MovieController {
    
    static var shared = MovieController()
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://mymovies-d5873.firebaseio.com/")!
    
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(NSError())
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error searching for movie with search term \(searchTerm): \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = try JSONDecoder().decode(MovieRepresentations.self, from: data).results
                self.searchedMovies = movieRepresentations
                completion(nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}


// Core Data
extension MovieController {
    
    // Create a new movie in the managed object context & save it to persistent store
    func addMovie(with title: String, hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let movie = Movie(title: title, hasWatched: hasWatched, context: context)
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error saving movie: \(error)")
        }
        put(movie: movie)
    }
    
    // Update an existing movie in the managed object context and save it to persistent store
    func update(movie: Movie) {
        movie.hasWatched = !movie.hasWatched
        
        put(movie: movie)
    }
    
    // Delete a movie in the managed object context and save the new managed object context
    // to persistent store
    func delete(movie: Movie) {
        
        deleteMovieFromServer(movie: movie)
        
        let moc = CoreDataStack.shared.mainContext
        moc.delete(movie)
        
        do {
            try CoreDataStack.shared.save(context: moc)
        } catch {
            moc.reset()
            NSLog("Error saving moc after deleting movie: \(error)")
        }
        
    }
    
    func movie(for identifier: String, in context: NSManagedObjectContext) -> Movie? {
        
        guard let identifier = UUID(uuidString: identifier) else { return nil }
    
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        let predicate = NSPredicate(format: "identifier == %@", identifier as NSUUID)
        fetchRequest.predicate = predicate
        
        var result: Movie? = nil
        
        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching movie with UUID: \(identifier): \(error)")
            }
        }
        
        return result
    }
    
}


// Networking
extension MovieController {
    
    // Typealias for completion handler
    typealias CompletionHandler = (Error?) -> Void
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion(error)
            }
            
            guard let data = data else {
                NSLog("No data returned from Firebase.")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({ $0.value })
                
                let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
                
                backgroundContext.performAndWait {
                    
                    for movieRep in movieRepresentations {
                        
                        guard let identifier = movieRep.identifier?.uuidString else
                        { return }
                        
                        if let _ = self.movie(for: identifier, in: backgroundContext) {} else {
                            let _ = Movie(movieRepresentation: movieRep, context: backgroundContext)
                        }
                        
                    }
                    
                    do {
                        try CoreDataStack.shared.save(context: backgroundContext)
                    } catch {
                        NSLog("Error saving background context: \(error)")
                    }
                    
                }
                
                completion(nil)
                
            } catch {
                NSLog("Error decoding Movie representations: \(error)")
                completion(error)
                return
            }
            
        }.resume()
        
    }
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        let identifier = movie.identifier ?? UUID()
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var movieRepresentation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            
            movieRepresentation.identifier = identifier
            movie.identifier = identifier
            
            try CoreDataStack.shared.save()
            
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
            
        } catch {
            NSLog("Error encoding Movie representation: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                NSLog("Error PUTing Movie: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            
        }.resume()
        
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        guard let identifier = movie.identifier else {
            NSLog("No identifier for Movie to delete")
            completion(NSError())
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            completion(error)
        }.resume()
        
    }
    
}
