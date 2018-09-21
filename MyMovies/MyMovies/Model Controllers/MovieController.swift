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
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    var searchedMovies: [MovieRepresentation] = []
    
    init() {
        fetchMoviesFromServer()
    }
    
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
    
    func createMovie(title: String, hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let movie = Movie(title: title, hasWatched: hasWatched)
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error creating an movie \(error)")
        }
        put(movie: movie)
    }
 
    func updateMovie(movie: Movie, hasWatched: Bool, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        movie.hasWatched = hasWatched
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error updating a movie \(error)")
        }
        put(movie: movie)
    }

    func update(movie: Movie, movieRepresentation: MovieRepresentation) {
        movie.title = movieRepresentation.title
        movie.identifier = movieRepresentation.identifier?.uuidString
        movie.hasWatched = movieRepresentation.hasWatched!
    }

    func deleteMovie(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let moc = CoreDataStack.shared.mainContext
        deleteFromServer(movie: movie)
        moc.delete(movie)
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error deleting a movie \(error)")
        }
    }

    func fetchSingleMovieFromPersistentStore(identifier: String, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "identifier == %@", identifier)
        fetchRequest.predicate = predicate
        
        var movie: Movie? = nil
        
        do {
            movie = try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching movie with UUID \(identifier): \(error)")
        }
        
        return movie
    }
    
    
    typealias CompletionHandler = (Error?) -> Void

    func put(movie: Movie, completion: @escaping CompletionHandler = {_ in } ) {
        guard let identifier = movie.identifier else { return }
        var requestURL = baseUrl.appendingPathComponent(identifier)
        requestURL.appendPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(movie)
        } catch {
            NSLog("Error encoding Movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) {data, _, error in
            if let error = error {
                NSLog("There was an error with the PUT Request: \(error)")
                completion(error)
            }
            
            completion(nil)
            }.resume()
        
    }
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = baseUrl.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) {data, _, error in
            if let error = error {
                NSLog("There was an error with the GET REQUEST: \(error)")
                completion(error)
            }
            
            guard let data = data else {
                NSLog("There was error unwrapping the data: \(error)")
                completion(error)
                return
            }
            
            var movieRepresentations: [MovieRepresentation] = []
            
            do {
                movieRepresentations = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({ $0.value })
                
                let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
                
                
                backgroundContext.performAndWait {
                    for movieRep in movieRepresentations {
                        if let movie = self.fetchSingleMovieFromPersistentStore(identifier: (movieRep.identifier?.uuidString)!, context: backgroundContext) {
                            if movie != movieRep {
                                print("goes to update")
                                self.update(movie: movie, movieRepresentation: movieRep)
                            }
                        } else {
                            print("goes to create")
                            _ = Movie(movieRepresentation: movieRep, context: backgroundContext)
                        }
                    }
                }
                
                do {
                    try CoreDataStack.shared.save(context: backgroundContext)
                } catch {
                    NSLog("Error creating an movie \(error)")
                }
                completion(nil)
            } catch {
                NSLog("There was an error decoding movies: \(error)")
                completion(error)
                return
            }
            }.resume()
    }
    
    func deleteFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let identifier = movie.identifier else { return }
        var requestURL = baseUrl.appendingPathComponent(identifier)
        requestURL.appendPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) {data, _, error in
            if let error = error {
                NSLog("There was an error with the DELETE Request: \(error)")
                completion(error)
            }
            
            completion(nil)
            }.resume()
    }
    
    let baseUrl = URL(string: "https://moinmovies-f80b0.firebaseio.com/")!

}
