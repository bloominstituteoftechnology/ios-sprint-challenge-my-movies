//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case post   = "POST"   // Create
    case get    = "GET"    // Read
    case put    = "PUT"    // Update/Replace
    case patch  = "PATCH"  // Update/Replace
    case delete = "DELETE" // Delete
}

class MovieController {
    
    // MARK: - Properties

    typealias CompletionHandler = (Error?) -> Void

    // Firebase
    let firebaseBaseURL = URL(string: "https://mymovies-lambda-gerrior.firebaseio.com/")!

    // The Movie DB
    var searchedMovies: [MovieRepresentation] = []
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    init() {
// FIXME: Add        fetchEntriesFromServer()
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
    
    // MARK: - CRUD
    
    // Create
    func create(identifier: UUID = UUID(),
                title: String,
                hasWatched: Bool = false) {
        
        let movie = Movie(identifier: identifier,
                          title: title,
                          hasWatched: hasWatched,
                          context: CoreDataStack.shared.mainContext)
        
        put(movie: movie)

        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving managed object context (after create) to Core Data: \(error)")
        }
    }

    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = firebaseBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        do {
            guard var representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
// FIXME: Necessary?            representation.identifier = uuid
            movie.identifier = uuid // TODO: ? What if it didn't change?
            request.httpBody = try JSONEncoder().encode(representation)
            
        } catch {
            NSLog("Error encoding/saving movie: \(error)")
            completion(error)
        }
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                NSLog("Error PUTing movie to server \(error)")
                completion(error)
                return
            }

            completion(nil)
        }.resume()
    }

    // Read

    // Update
    func update(movie: Movie,
                title: String,
                hasWatched: Bool = true) {

        movie.title = title
        movie.hasWatched = hasWatched
        
        put(movie: movie)

        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving managed object context (after update) to Core Data: \(error)")
        }
    }

    // Delete
    func delete(movie: Movie) {

        // TODO: ? Was this one necessary to wrap?
        let context = CoreDataStack.shared.mainContext

        context.performAndWait {
            context.delete(movie)
        }

        // Delete from Firebase (copy of record)
        delete(movie: movie) { _ in print("Deleted") }

        // Delete from Core Data
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving managed object context (after delete) to Core Data: \(error)")
        }
    }

    func delete(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = firebaseBaseURL
            .appendingPathComponent(movie.identifier!.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                NSLog("Error DELETEing entry from server \(error)")
                completion(error)
                return
            }

            completion(nil)
        }.resume()
    }
}
