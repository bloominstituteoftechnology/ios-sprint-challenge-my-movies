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
        fetchMoviesFromServer()
    }
    
    // MARK: - CRUD Methods
    
    func createMovie(title: String, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        let movie = Movie(title: title, context: context)
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error saving movie: \(error)")
        }
        
        put(movie: movie)
    }
    
    func updateMovie(movie: Movie, hasWatched: Bool) {
        movie.hasWatched = hasWatched
        
        put(movie: movie)
    }
    
    func delete(movie: Movie) {
        let moc = CoreDataStack.shared.mainContext
        
        deleteMovieFromServer(movie: movie)
        
        moc.delete(movie)
        
        do {
            try CoreDataStack.shared.save(context: moc)
        } catch {
            moc.reset()
            NSLog("Error saving moc after deleting movie: \(error)")
        }
    }
    
    // MARK: - API Search Query
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
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
    
    // MARK: - Networking (Firebase)
    
    
    func put(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let identifier = movie.identifier else {
            NSLog("No identifier")
            completion(NSError())
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            
            let context = movie.managedObjectContext ?? CoreDataStack.shared.mainContext
            try context.save()
            
            request.httpBody = try JSONEncoder().encode(movie)
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting movie: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let identifier = movie.identifier else {
            NSLog("No identifier for task to delete.")
            completion(NSError())
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let error = error {
                NSLog("Error deleting movie from server: \(error)")
                completion(error)
                return
            }
            
            print(response!)
            completion(nil)
        }.resume()
    }
    
    // MARK: - Persistent Store
    
    func fetchSingleMovieFromPS(identifier: String, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        
        var movie: Movie? = nil
        context.performAndWait {
            do {
                movie = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching entry with given identifier: \(error)")
            }
        }
        return movie
    }
    
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        let url = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching data: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else { return }
            
            var movieRepresentations: [MovieRepresentation] = []
            
            do {
                let resultsDictionary = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
                movieRepresentations = resultsDictionary.map({  $0.value })
                
                let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
                
                backgroundContext.performAndWait {
                    self.checkMovieRepresentation(movieRepresentations: movieRepresentations, context: backgroundContext)
                    do {
                        try CoreDataStack.shared.save(context: backgroundContext)
                    } catch {
                        NSLog("Error saving movies after fetching them: \(error)")
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
    
    // MARK: - Private Functions
    
    private func update(movie: Movie, movieRepresentation: MovieRepresentation) {
        
        guard let hasWatched = movieRepresentation.hasWatched else { return }
        
        movie.title = movieRepresentation.title
        movie.identifier = movieRepresentation.identifier
        movie.hasWatched = hasWatched
    }
    
    private func checkMovieRepresentation(movieRepresentations: [MovieRepresentation], context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        for movieRep in movieRepresentations {
            
            guard let identifier = movieRep.identifier?.uuidString else { return }
            
            if let movie = self.fetchSingleMovieFromPS(identifier: identifier, context: context) {
                
                self.update(movie: movie, movieRepresentation: movieRep)
            } else {
                let _ = Movie(movieRepresentation: movieRep)
            }
        }
    }
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    static let baseURL = URL(string: "https://mymovies-cce4f.firebaseio.com/")!
}
