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
        fetchMovieFromServer()
    }
    
    typealias Completionhandler = (Error?) -> Void
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    
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
    
    
    // MARK: - Core Data Methods
    
    // CREATE
    func create(title: String, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let movie = Movie(title: title, context: context)
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error saving movie: \(error)")
        }
        
        put(movie: movie)
    }
    
    // UPDATE
    func update(movie: Movie, hasWatched: Bool) {
        movie.hasWatched = hasWatched
        put(movie: movie)
    }
    
    // DELETE
    func delete(movie: Movie) {
        let moc = CoreDataStack.shared.mainContext
        deleteMovieFromServer(movie: movie)
        moc.delete(movie)
        
        do {
            try CoreDataStack.shared.save(context: moc)
        } catch {
            moc.reset()
            NSLog("Error saving moc aster deleting task: \(error)")
        }
    }
    
    // FETCH SINGLE MOVIE FROM PERSISTENT STORE
    func fetchSingleMovieFromPersistentStore(identifier: String, context: NSManagedObjectContext) -> Movie? {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "identifier == %@", identifier)
        fetchRequest.predicate = predicate
        
        var result: Movie? = nil
        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching task with UUID \(identifier): \(error)")
            }
        }
        return result
    }
    
    
    static let baseURL = URL(string: "https://mymovies-dff7e.firebaseio.com/")!
    
    
    // MARK: - Server Methods
    
    private func update(movie: Movie, movieRepresentation: MovieRepresentation) {
        
        movie.title = movieRepresentation.title
        movie.hasWatched  = movieRepresentation.hasWatched ?? false
        movie.identifier = movieRepresentation.identifier
    }
    
    
    // FETCH MOVIES FROM SERVER
    func fetchMovieFromServer(completion: @escaping Completionhandler = { _ in }) {
        let requestURL = MovieController.baseURL.appendingPathExtension("json")
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching data: \(error)")
                completion(error)
                return
            }
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({ $0.value })
                let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
                
                backgroundContext.performAndWait {
                    
                    for movieRep in movieRepresentations {
                        guard let identifier = movieRep.identifier?.uuidString else { return }
                        if let movie = self.fetchSingleMovieFromPersistentStore(identifier: identifier, context: backgroundContext) {
                            self.update(movie: movie, movieRepresentation: movieRep)
                        } else {
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
                NSLog("Error decoding data: \(error)")
                completion(error)
                return
            }
            
            }.resume()
    }
    
    
    // PUT MOVIE ON SERVER
    func put(movie: Movie, completion: @escaping Completionhandler = { _ in }) {
        let identifier = movie.identifier ?? UUID()
        let requestURL = MovieController.baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movie)
        } catch {
            NSLog("Error encoding movie representation: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTTing movie")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    // DELETE MOVIE FROM SERVER
    func deleteMovieFromServer(movie: Movie, completion: @escaping Completionhandler = { _ in }) {
        
        guard let identifier = movie.identifier else {
            NSLog("No identifer for movie to delete")
            completion(NSError())
            return
        }
        
        let requestURL = MovieController.baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error DELETEing movie")
                completion(error)
                return
            }
            }.resume()
    }
    
}
