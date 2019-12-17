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
    
    // Fetches the current Core Data entries
    func fetchMovies() {
        let fetchRequest: NSFetchRequest<Movies> = Movies.fetchRequest()
        let moc = CoreDataStack.shared.mainContext
        do {
            let movies = try? moc.fetch(fetchRequest)
            
        }
    }
    
    func update(with representations: [MovieRepresentation]) {
        let entriesWithID = representations.filter({ $0.identifier != nil })
        let identifiersToFetch = entriesWithID.compactMap({ UUID(uuidString: $0.identifier!) })
        
        let representationByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, entriesWithID))
        
        var entriesToCreate = represenationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        let representation = representationsByID[identifier] else { continue }
        self.update(entry: entry, with: represenation)
        
        entriesToCreate.removeValue(forKey: identifier)
    }

    
    // Saves content to Core Data
    func saveMovie() {
        let moc = CoreDataStack.shared.mainContext
        do {
          try moc.save()
        } catch {
            print("There was a problem saving: \(error)")
        }
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
