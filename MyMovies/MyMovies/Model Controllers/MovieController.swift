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
    
    init() {
        fetchFromServer()
    }
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://stefanojournal.firebaseio.com")!
    typealias CompletionHandler = (Error?) -> Void
    
    enum HTTPMethods: String {
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    // MARK: - HTTPMethods
    
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
    
    func fetchFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let url = firebaseURL.appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = try Array(JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
                try self.syncPersistentStore(with: movieRepresentations, in: backgroundContext)
                completion(nil)
            } catch {
                NSLog("Error decoding movies: \(error)")
                completion(error)
                return
            }
            
        }.resume()
    }
    
    func putToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let identifier = movie.identifier else {
            NSLog("Movie has no identifier")
            completion(NSError())
            return
        }
        
        let url = firebaseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.put.rawValue
        
        do {
            let encodedMovie = try JSONEncoder().encode(movie)
            request.httpBody = encodedMovie
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error putting movie to server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    func deleteFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let identifier = movie.identifier else {
            NSLog("Movie has no identifier")
            completion(NSError())
            return
        }
        
        let url = firebaseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error deleting movie from server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    // MARK: - Persistence Methods
    
    func create(title: String, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            let movie = Movie(title: title)
            putToServer(movie: movie)
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving in context \(context): \(error)")
            }
        }
    }
    
    func update(_ movie: Movie, with movieRep: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            guard let hasWatched = movieRep.hasWatched else { return }
            
            movie.title = movieRep.title
            movie.hasWatched = hasWatched
            movie.identifier = movieRep.identifier
        }
    }
    
    func toggleWatched(for movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            movie.hasWatched = !movie.hasWatched
            putToServer(movie: movie)
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving in context \(context): \(error)")
            }
        }
    }
    
    func delete(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            context.delete(movie)
            deleteFromServer(movie: movie)
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving in context \(context): \(error)")
            }
        }
    }
    
    func syncPersistentStore(with movieReps: [MovieRepresentation], in context: NSManagedObjectContext) throws {
        var error: Error?
        
        for movieRep in movieReps {
            if let movie = self.fetchFromPersistenceStore(with: movieRep, context: context) {
                if movie != movieRep {
                    self.update(movie, with: movieRep)
                }
            } else {
                let _ = Movie(title: movieRep.title)
            }
        }
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch let syncError {
            NSLog("Error syncing with persistent store: \(syncError)")
            error = syncError
        }
        
        if let error = error { throw error }
    }
    
    func fetchFromPersistenceStore(with movieRep: MovieRepresentation, context: NSManagedObjectContext) -> Movie? {
        var movie: Movie?
        guard let identifier = movieRep.identifier else {
            NSLog("No identifier for movie: \(movieRep)")
            return nil
        }
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "identifier == %@", identifier as CVarArg)
        fetchRequest.predicate = predicate
        
        context.performAndWait {
            do {
                movie = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching movie from persistent store: \(error)")
            }
        }
        
        if let movie = movie { return movie } else { return nil }
    }
    
    // MARK: - Helper Methods
    
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
