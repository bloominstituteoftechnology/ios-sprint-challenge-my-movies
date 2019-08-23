//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String {
    case get    = "GET"
    case put    = "PUT"
    case post   = "POST"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case noAuth
    case badAuth
    case otherError(Error)
    case badData
    case noDecode
}

class MovieController {
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let fireBaseURL = URL(string: "https://mymovies-fda69.firebaseio.com/")!
    
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
    
    // MARK: - CRUD Methods
    
    // Create
    func createMovie(with title: String, hasWatched: Bool, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            let movie = Movie(title: title, hasWatched: hasWatched)
            do{
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving context when creating new task :\(error)")
            }
            put(movie: movie)
        }
    }
    
    // Update
    func updateMovie(movie: Movie, with title: String, hasWatched: Bool, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            movie.title = title
            movie.hasWatched = hasWatched
          
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving context when updating entry:\(error)")
            }
            put(movie: movie)
        }
    }
    
    // Update Movie with Entry Representation Method
    func update(movie: Movie, with movieRepresentation: MovieRepresentation) {
        guard let hasWatched = movieRepresentation.hasWatched else { return }
        movie.title      = movieRepresentation.title
        movie.identifier = movieRepresentation.identifier
        movie.hasWatched = hasWatched
    }
    
    // Delete
    func deleteMovie(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        deleteMovieFromServer(movie: movie)
        context.performAndWait {
            context.delete(movie)
            
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving context when deleting entry:\(error)")
            }
        }
    }


    
    // PUT Movie in fireBase Data Base
    func put(movie: Movie, completion: @escaping () -> Void = { }) {
        guard let identifier = movie.identifier else { return }
        
        let requestURL = fireBaseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        do {
            let entryData    = try JSONEncoder().encode(movie.movieRepresentation)
            request.httpBody = entryData
        } catch {
            NSLog("Error encoding movie representation:\(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                NSLog("Error PUTing entryRep to server:\(error)")
            }
            completion()
        }.resume()
    }
    
    // DELETE Movie from Firebase
    func deleteMovieFromServer(movie: Movie, completion: @escaping(NetworkError?) -> Void = { _ in }) {
        guard let identifier = movie.identifier else {
            completion(.noAuth)
            return
        }
        
        let requestURL     = fireBaseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var request        = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting movie:\(error)")
            }
            completion(nil)
            }.resume()
    }
    
    // Fetch SINGLE Movie From Firebase Server Method
    func fetchSingleMovieFromPersistentStore(identifier: String, context: NSManagedObjectContext) -> Movie? {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        var movie: Movie? = nil
        context.performAndWait {
            do {
                movie = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching entry with identifier \(identifier):\(error)")
                movie = nil
            }
        }
        return movie
    }
    
    // Fetch ALL Movies From FireBase Server Method
    func fetchMoviesFromServer(completion: @escaping() -> Void) {
        
        let requestURL     = fireBaseURL.appendingPathExtension("json")
        var request        = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                NSLog("Error fetching movies from server:\(error)")
                completion()
                return
            }
            
            guard let data = data else {
                NSLog("Error GETing data for all movies")
                completion()
                return
            }
            
            do {
                let moviesDictionary = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
                let movieRepArray     = moviesDictionary.map({ $0.value })
                let moc               = CoreDataStack.shared.container.newBackgroundContext()
                
                self.updatePersistentStore(forMovieIn: movieRepArray, for: moc)
            } catch {
                NSLog("error decoding movies:\(error)")
            }
            completion()
        }.resume()
    }
    
    
    
    func updatePersistentStore(forMovieIn movieRepresentations: [MovieRepresentation], for context: NSManagedObjectContext) {
        context.performAndWait {
            
            for movieRep in movieRepresentations {
                guard let identifier = movieRep.identifier else { continue }
                
                if let movie = self.fetchSingleMovieFromPersistentStore(identifier: identifier, context: context) {
                    guard let hasWatched = movieRep.hasWatched else { return }
                    movie.title      = movieRep.title
                    movie.identifier = movieRep.identifier
                    movie.hasWatched = hasWatched
                } else {
                    Movie(movieRepresentation: movieRep, context: context)
                }
            }
            
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving context: \(error)")
                context.reset()
            }
        }
    }
    
}
