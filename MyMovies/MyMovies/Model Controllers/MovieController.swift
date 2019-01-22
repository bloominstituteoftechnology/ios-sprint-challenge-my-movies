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
    private let movieURL = URL(string: "https://coredata-mymovies.firebaseio.com/")!
    
    init() {
        fetchMoviesFromServer()
    }
    
    // MARK: - API Methods
    
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
    
    // MARK: - Firebase Methods
    
    func fetchMoviesFromServer(completion: @escaping ((Error?) -> Void) = { _ in }) {
    
        let requestURL = movieURL.appendingPathExtension("json")
    
            URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
    
                if let error = error {
                    NSLog("Error fetching Entry: \(error)")
                    completion(error)
                    return
                }
    
                guard let data = data else {
                    NSLog("No data returned from data task")
                    completion(NSError())
                    return
                }
    
                var movieRepresentations: [MovieRepresentation] = []
    
                do {
                    movieRepresentations = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({ $0.value })
    
                } catch {
                    NSLog("Error decoding JSON: \(error)")
                    completion(error)
                    return
                }
    
                let backgroundMoc = CoreDataStack.shared.container.newBackgroundContext()
                backgroundMoc.performAndWait {
    
                    for movieRepresentation in movieRepresentations {
    
                         if  let identifier = movieRepresentation.identifier,
                            let movie = self.fetchSingleMovieFromPersistentStore(identifier: identifier, context: backgroundMoc) {
    
                            if movie != movieRepresentation {
                                self.update(movie: movie, with: movieRepresentation)
                            }
                            
                        } else {
                            self.create(movieRepresentation: movieRepresentation, context: backgroundMoc)
                            }
                        
                    }
                }
    
                do {
                    try CoreDataStack.shared.save(context: backgroundMoc)
                } catch {
                    NSLog("Error saving background context: \(error)")
                    completion(nil)
                    return
                }
                completion(nil)
                return
    
            }.resume()
    }
    
    func fetchSingleMovieFromPersistentStore(identifier: UUID, context: NSManagedObjectContext) -> Movie? {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier as NSUUID)
        
        var movie: Movie? = nil
        
        context.performAndWait {
            do {
                movie = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching single entry: \(error)")
            }
        }
        return movie
    }
    
    func put(movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        
        let uuid = movie.identifier ?? UUID()
        let requestURL = movieURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movie)
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting movie to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
            return
        }.resume()
    }
    
    func deleteFromServer(movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        
        guard let uuid = movie.identifier else {
            NSLog("No identifier found")
            completion(NSError())
            return
        }
        
        let requestURL = movieURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting movie: \(error)")
                completion(error)
                return
            }
            completion(nil)
            return
            }.resume()
    }
    
    // MARK: - CRUD Methods
    
    func create(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let hasWatched = movieRepresentation.hasWatched ?? false
        let identifier = movieRepresentation.identifier ?? UUID()
        let movie = Movie(title: movieRepresentation.title, identifier: identifier, hasWatched: hasWatched, context: context)
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            print("Failed to save: \(error)")
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
            print("Failed to save after deleting movie: \(error)")
        }
    }
    
    func updateWatchedButton(movie: Movie) {
        movie.hasWatched = !movie.hasWatched
        guard let context = movie.managedObjectContext else { return }
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            print("Failed to save: \(error)")
        }
        put(movie: movie)
    }
    
    // MARK: - Properties
    var movieRepresentation: MovieRepresentation?
    var searchedMovies: [MovieRepresentation] = []
}
