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
    
    typealias CompletionHandler = (Error?) -> Void
    
    static let firebaseURL = URL(string: "https://mymoviestest-fe9af.firebaseio.com")!
    
    // MARK: - CRUD Methods
    
    func createMovie(title: String, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let moc = CoreDataStack.shared.mainContext
        let movie = Movie(title: title)
        
        do {
            try CoreDataStack.shared.save(context: moc)
        } catch {
            NSLog("Error saving movie: \(error)")
        }
        
        put(movie: movie)
        
    }
    
    func updateMovie(movie: Movie, hasWatched: Bool){
        movie.hasWatched = hasWatched
    }
    
    func deleteMovie(movie: Movie){
        let moc = CoreDataStack.shared.mainContext
        
        // delete from Server
        
        moc.delete(movie)
        
        do {
            try CoreDataStack.shared.save(context: moc)
        } catch {
            NSLog("Error deleting movie: \(error)")
        }
        
    }
    
    // firebase server functions
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let url = MovieController.firebaseURL.appendingPathExtension("json")
        
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
                
                do {
                    try CoreDataStack.shared.save(context: backgroundContext)
                } catch {
                    NSLog("Error saving movies after fetching them: \(error)")
                }
                
                
                completion(nil)
            } catch {
                NSLog("Error decoding data: \(error)")
                completion(error)
                return
            }
            
            }.resume()
    }
    
    // PUT
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        guard let identifier = movie.identifier else {
            NSLog("No identifier")
            completion(NSError())
            return
        }
        
        let requestURL = MovieController.firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movie)
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        do {
            let context = movie.managedObjectContext ?? CoreDataStack.shared.mainContext
            try context.save()
        } catch {
            NSLog("Error saving updated movie: /(error)")
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
    
    // DELETE
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        guard let identifier = movie.identifier else {
            NSLog("No identifier for task to delete.")
            completion(NSError())
            return
        }
        
        let requestURL = MovieController.firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
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
    
    
    // API call to server
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
    
}

// Extensions

extension Movie: Encodable {
    enum CodingKeys: String, CodingKey {
        case title
        case identifier
        case hasWatched
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.title, forKey: .title)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.hasWatched, forKey: .hasWatched)
    }}
