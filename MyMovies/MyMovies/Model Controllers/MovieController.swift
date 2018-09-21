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
    
    // MARK: - CRUD Methods
    func create(title: String, hasWatched: Bool = false, identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let movie = Movie(title: title, hasWatched: hasWatched, identifier: identifier, context: context)
        
        context.performAndWait {
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving created movie: \(error)")
                return
            }
        }
        
        put(movie: movie)
    }
    
    /// Toggles the hasWatched property on the given movie. Intended to update a single movie at a time, by the user's action.
    func toggleHasWatchedOn(movie: Movie) {
        movie.hasWatched = !movie.hasWatched
        
        guard let context = movie.managedObjectContext else { fatalError("Movie has no context.") }
        
        context.performAndWait {
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving updated movie: \(error)")
                return
            }
        }
        
        put(movie: movie)
    }
    
    func delete(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        deleteFromServer(movie: movie)
        
        context.delete(movie)
        
        context.performAndWait {
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving after deleting movie: \(error)")
            }
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
}
