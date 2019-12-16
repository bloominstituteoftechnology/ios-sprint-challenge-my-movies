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
    private let firebaseURL = URL(string: "https://mymovies-1962c.firebaseio.com/")!
    
    // MARK: - Properties
    var searchedMovies: [MovieRepresentation] = []
    
    
    init() {
        fetchMoviesFromServer()
    }
    
    // MARK: - Fetch
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void = {_ in }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { data, _, error in
            guard error == nil else {
                print("Error fetching movies: \(error!)")
                completion(error)
                return
            }
            
            guard let data = data else {
                print("No data returned by data task")
                completion(NSError())
                return
            }
            
            do {
                var savedMovies: [MovieRepresentation] = []
                savedMovies = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                
                try self.updateMovies(with: savedMovies)
                completion(nil)
            } catch {
                print("Error decoding movies: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    // MARK: - Search API
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
    
    // MARK: - Put to Server
    func put(movie: Movie, completion: @escaping (Error?) -> Void = {_ in }) {
        guard let identifier = movie.identifier?.uuidString else { return }
        let requestURL = firebaseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var representation = movie.movieRepresentation else {
                print("Error creating MovieRepresentation in PUT")
                completion(nil)
                return
            }
            
            representation.identifier = identifier
            movie.identifier = UUID(uuidString: identifier)
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding movie \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil else {
                print("Error PUTing movie to server: \(error!)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    // MARK: - Update Core Data
    func updateMovies(with representations: [MovieRepresentation]) throws {
        let moviesWithID = representations.filter { $0.identifier != nil }
        let identifiersToFetch = moviesWithID.compactMap { $0.identifier }
        
        let representationByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
        
        var moviesToCreate = representationByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let moc = CoreDataStack.shared.container.newBackgroundContext()
        
        moc.perform {
        do {
            let existingMovies = try moc.fetch(fetchRequest)
            
            for movie in existingMovies {
                guard let id = movie.identifier?.uuidString,
                    let representation = representationByID[id] else {
                        // if we fetched from the server and found that we have an item in core data that is not on the server, the core data item is deleted.
                        let moc = CoreDataStack.shared.mainContext
                        moc.delete(movie)
                        continue
                }
                
                // overwrites the core data values with the values from the server.
                self.update(movie: movie, representation: representation)
                
                // removes that item from the array and moves on to the next one.
                moviesToCreate.removeValue(forKey: id)
                // at the completion of this loop above, the remaining entries in entriesToCreate are ones that existed in the server but not in core data.
            }
            
            // create new entries in core data that were on the server but not core data.
            for representation in moviesToCreate.values {
                Movie(movieRepresentation: representation, context: moc)
            }
        } catch {
            print("Error fetching tasks for identifiers: \(error)")
        }
        }
        try CoreDataStack.shared.save(context: moc)
    }
    
    // MARK: - Delete from Server
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping (Error?) -> Void = {_ in }) {
        guard let identifier = movie.identifier?.uuidString else {
            completion(NSError())
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            guard error == nil else {
                print("Error deleting task: \(error!)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    // MARK: - Helper Methods
    func createMovie(for movie: Movie) {
            put(movie: movie)
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error creating movie to core data")
        }
    }
    
    func updateMovie(for movie: Movie) {
        put(movie: movie)
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error update movie to core data")
        }
    }
    
    func deleteMovie(for movie: Movie) {
        let moc = CoreDataStack.shared.mainContext
        moc.delete(movie)
        deleteMovieFromServer(movie)
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error updating movie during delete")
        }
    }
    
    private func update(movie: Movie, representation: MovieRepresentation) {
        guard let hasWatched = representation.hasWatched else { return }
        movie.title = representation.title
        movie.identifier = UUID(uuidString: representation.identifier ?? UUID().uuidString)
        movie.hasWatched = hasWatched
    }

}
