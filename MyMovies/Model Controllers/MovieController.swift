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
    let apiController = APIController()
    
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
    
    func clearSearchForMovies() {
        searchedMovies = []
    }
    
    // Fetches the current Core Data entries
    func fetchMovies() {
        let fetchRequest: NSFetchRequest<Movies> = Movies.fetchRequest()
        let moc = CoreDataStack.shared.mainContext
        do {
            let movies = try? moc.fetch(fetchRequest)
        } catch {
            print("Error Fetching: \(error)")
        }
    }
    
  
        

    // MARK: - CRUD Data Model Methods
    
    
    func create(title: String) {
        let moc = CoreDataStack.shared.mainContext
        let newMovie = Movies(context: moc,
                              hasWatched: false,
                              identifier: UUID().uuidString,
                              title: title)
        try? moc.save()
    }
    
    // Saves content to Core Data
    func save() {
        let moc = CoreDataStack.shared.mainContext
        do {
          try moc.save()
        } catch {
            print("There was a problem saving: \(error)")
        }
    }
    
    func update(movie: Movies) {
        
        
    }
    
    func delete(movie: Movies) {
        
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
