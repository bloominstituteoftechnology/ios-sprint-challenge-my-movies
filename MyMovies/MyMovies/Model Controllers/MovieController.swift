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
    
    // MARK: - Properties
    var searchedMovies: [MovieRepresentation] = []
    
    private let serverBaseURL = URL(string: "https://watched-movies-list.firebaseio.com/")!
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let moviesBaseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    // MARK: - Initializers
    init() {
        fetchMovies()
    }
    
    // MARK: - CRUD Methods
    func createMovie(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let hasWatched = movieRepresentation.hasWatched ?? false
        let identifier = movieRepresentation.identifier ?? UUID()
        
        let movie = Movie(title: movieRepresentation.title, hasWatched: hasWatched, identifier: identifier, context: context)
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error saving created movie: \(error)")
            return
        }
        
        put(movie: movie)
    }
    
    /// Toggles the hasWatched property on the given movie. Intended to update a single movie at a time, by the user's action.
    func toggleHasWatchedOn(movie: Movie) {
        movie.hasWatched = !movie.hasWatched
        
        guard let context = movie.managedObjectContext else { fatalError("Movie has no context.") }
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error saving updated movie: \(error)")
            return
        }
        
        put(movie: movie)
    }
    
    func update(movie: Movie, with movieRepresentation: MovieRepresentation) {
        movie.title = movieRepresentation.title
        movie.hasWatched = movieRepresentation.hasWatched ?? false
    }
    
    func delete(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        deleteFromServer(movie: movie)
        
        context.delete(movie)
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error saving after deleting movie: \(error)")
        }
    }
    
    // MARK: - Networking
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        
        var components = URLComponents(url: moviesBaseURL, resolvingAgainstBaseURL: true)
        
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
    
    private func fetchMovies(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = serverBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movies from server: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data was returned.")
                completion(NSError())
                return
            }
            
            var movieRepresentations: [MovieRepresentation] = []
            
            do {
                movieRepresentations = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map() { $0.value }
                
            } catch {
                NSLog("Error decoding movie representations: \(error)")
                completion(error)
                return
            }
            
            let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
            
            
            backgroundContext.performAndWait {
                self.updatePersistentStore(with: movieRepresentations, context: backgroundContext)
            }
            
            do {
                try CoreDataStack.shared.save(context: backgroundContext)
            } catch {
                NSLog("Error saving background context after updating with movies from server.")
                completion(error)
                return
            }
            
            completion(nil)
            return
            
        }.resume()
    }
    
    private func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        guard let identifier = movie.identifier else {
            NSLog("Movie has no identifier")
            completion(NSError())
            return
        }
        
        let requestURL = serverBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        do {
            request.httpBody = try JSONEncoder().encode(movie)
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTting movie to server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            return
        }.resume()
    }
    
    private func deleteFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let identifier = movie.identifier else {
            NSLog("Movie has no identifier")
            completion(NSError())
            return
        }
        
        let requestURL = serverBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error DELETEing movie from server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            return
        }.resume()
    }
    
    // MARK: - Utility Methods
    private func fetchSingleMovie(identifier: UUID, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        let predicate = NSPredicate(format: "identifier = %@", identifier as NSUUID)
        
        fetchRequest.predicate = predicate
        
        var movie: Movie? = nil
        
        context.performAndWait {
            do {
                movie = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching single movie: \(error)")
            }
        }
        return movie
    }
    
    private func updatePersistentStore(with movieRepresentations: [MovieRepresentation], context: NSManagedObjectContext) {
        for movieRepresentation in movieRepresentations {
            if let identifier = movieRepresentation.identifier, let movie = fetchSingleMovie(identifier: identifier, context: context) {
                if movie != movieRepresentation {
                    // Update movie, because one with the same identifier exists, but it isn't equal.
                    update(movie: movie, with: movieRepresentation)
                }
            } else {
                // There is no movie with that identifier, create a new one.
                createMovie(movieRepresentation: movieRepresentation, context: context)
            }
        }
    }
}
