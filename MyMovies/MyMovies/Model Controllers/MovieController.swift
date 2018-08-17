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
    
    
    // MARK: - Networking
    
    // MARK: The Movie DB search API
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let searchAPIBaseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        
        var components = URLComponents(url: searchAPIBaseURL, resolvingAgainstBaseURL: true)
        
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
    
    // MARK: Firebase server
    private let storageServerBaseURL = URL(string: "https://samsmovieapp.firebaseio.com/")!
    
    // Fetches saved movies
    func fetch(completion: @escaping (Error?) -> Void = { _ in }) {
        let requestURL = storageServerBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching data: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(error)
                return
            }
            
            do {
                let movieRepDicts = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
                let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
                try self.updateMovieList(for: movieRepDicts, context: backgroundContext)
                completion(nil)
            } catch {
                NSLog("Error decoding data: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    func put(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        // Movie's should always have an identifier
        guard let identifierString = movie.identifier?.uuidString else { return }
        
        let requestURL = storageServerBaseURL
            .appendingPathComponent(identifierString)
            .appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movie)
        } catch {
            NSLog("Error encoding data: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTting data: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func deleteFromServer(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        guard let identifierString = movie.identifier?.uuidString else { return }
        
        let requestURL = storageServerBaseURL
            .appendingPathComponent(identifierString)
            .appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting movie: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    
    // MARK: - CoreData
    
    func save(context: NSManagedObjectContext) {
        context.performAndWait {
            do {
                try context.save()
            } catch {
                NSLog("Error saving movies: \(error)")
            }
        }
    }
    
    func fetchMovieFromPersistentStore(with identifier: UUID, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", identifier.uuidString)
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching movie with identifier \(identifier): \(error)")
            return nil
        }
    }
    
    func updateMovieList(for movieRepDicts: [String: MovieRepresentation], context: NSManagedObjectContext) throws {
        
        context.performAndWait {
            for movieRep in movieRepDicts.values {
                guard let identifier = movieRep.identifier else { return }
                let movie = fetchMovieFromPersistentStore(with: identifier, context: context)
                
                if let movie = movie {
                    
                    if movie != movieRep {
                        updateFromRepresentaion(movie: movie, movieRep: movieRep)
                    }
                    
                } else {
                    _ = Movie(movieRep: movieRep, context: context)
                }
            }
            save(context: context)
        }
    }
    
    
    // MARK: - CRUD
    
    func addMovie(from movieRep: MovieRepresentation, context: NSManagedObjectContext) {
        // When we add a movie we're going to want to convert the movie rep into an actual movie
        // the moviecell will have the movie rep
        
        let movie = Movie(movieRep: movieRep, context: CoreDataStack.moc)
        put(movie: movie)
        save(context: context)
    }
    
    func updateFromRepresentaion(movie: Movie, movieRep: MovieRepresentation) {
        // Movie rep is coming from the firebase server so should always have a hasWatched bool
        guard let hasWatched = movieRep.hasWatched else { return }
        movie.hasWatched = hasWatched
    }
    
    func toggleHasWatched(movie: Movie, context: NSManagedObjectContext) {
        movie.hasWatched = !movie.hasWatched
        save(context: context)
        put(movie: movie)
    }
    
    func delete(movie: Movie, context: NSManagedObjectContext) {
        deleteFromServer(movie: movie)
        context.delete(movie)
        save(context: context)
    }
}
