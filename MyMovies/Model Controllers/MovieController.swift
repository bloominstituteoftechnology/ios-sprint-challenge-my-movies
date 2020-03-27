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
    
    // MARK: - Movie API
    
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
    
    // MARK: - Firebase
    
    private let fireURL = URL(string: "https://mymovies-77687.firebaseio.com/")
    
    // MARK: - Core Data
    
    // Create
    func create(title: String) {
        let movie = Movie(identifier: UUID(), title: title, hasWatched: false, context: CoreDataStack.shared.mainContext)
        saveToPersistentStore()
    }
    
    // Persistence
    func saveToPersistentStore(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error saving managed object context: \(error)")
            context.reset()
        }
    }
    
    // Convert a single movie representation into coreData. From movieDB -> CoreData
    
    func updateSingleRep(representation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        context.performAndWait {
            do {
                // Get all movies in core data
                let existingMovies = try context.fetch(fetchRequest)
                // Try to find a matching title
                if let foundIndex = existingMovies.firstIndex(where: {$0.title == representation.title}) {
                    print("Movie already exists")
                } else {
                    create(title: representation.title)
                }
            } catch {
                NSLog("Error Creating a goodie")
            }
        }
        
    }
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
