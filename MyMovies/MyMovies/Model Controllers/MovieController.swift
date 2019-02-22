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
    
    private let firebaseURL = URL(string: "https://mymovies-64f31.firebaseio.com/")!
    
    init() {
        
    }
    
    func create(withTitle title: String) {
        
    }
    
    func update() {
        
    }
    
    func delete(movie: Movie) {
        
    }
    
    func updateFromRepresentation() {
        
    }
    
    func updateMovies(with representations: [MovieRepresentation], context: NSManagedObjectContext) throws {
        
        context.performAndWait {
            
            for movieRepresentation in representations {
                
                guard let identifier = movieRepresentation.identifier else { continue }
                
                if let movie = self.fetchMovieFromStore(identifier: identifier, context: context) {
                    self.updateFromRepresentation()
                } else {
                    let _ = Movie(movieRepresentation: movieRepresentation, context: context)
                }
                
                
            }
        }
    }
    
    
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping(Error?) -> Void = { _ in }) {
        guard let identifier = movie.identifier else { return }
        
        let requestURL =
            firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
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
    
    func toggleHasWatched(for movie: Movie) {
        if movie.hasWatched == false {
            movie.hasWatched = true
        } else {
            movie.hasWatched = false
        }
    }
    
    func put(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        guard let identifier = movie.identifier else { completion(NSError()); return }
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movie)
        }
        catch {
            NSLog("Error encoding data: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTing data: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func fetchMovieFromStore(identifier: UUID, context: NSManagedObjectContext) {
        
    }
    
    func fetchMovieFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching data: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("There is no data.")
                completion(NSError())
                return
            }
            
            do {
                movieRepresentations = try Array(JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                let moc = CoreDataStack.shared.container.newBackgroundContext()
                try self.updateMovies(with: movieRepresentations, context: moc)
                completion(nil)
            }
            catch {
                NSLog("Error decoding JSON: \(error)")
                completion(error)
                return
            }
        
    }
    
    // MARK: - Networking
    
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
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    var movies: [Movie] = []
}
