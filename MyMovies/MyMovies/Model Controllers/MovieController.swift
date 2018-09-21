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
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    // MARK: - CRUD Methods
    func create(title: String, hasWatched: Bool = false, identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let movie = Movie(title: title, hasWatched: hasWatched, identifier: identifier, context: context)
        
        context.performAndWait {
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving created movie: \(error)")
            }
        }
        
        // TODO: PUT the new movie to the server
    }
    
    /// Updates the given movie with the given properties. Intended to update a single movie at a time, by the user's action.
    func update(movie: Movie, title: String, hasWatched: Bool, identifier: UUID) {
        movie.title = title
        movie.hasWatched = hasWatched
        movie.identifier = identifier
        
        guard let context = movie.managedObjectContext else { fatalError("Movie has no context.") }
        
        context.performAndWait {
            do {
                try CoreDataStack.shared.save(context: context)
                // TODO: PUT the updated movie to the server
            } catch {
                NSLog("Error saving updated movie: \(error)")
            }
        }
    }
    
    // MARK: - Networking
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
    
}
