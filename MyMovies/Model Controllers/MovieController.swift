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
    typealias CompletionHandler = (Error?) -> Void
    var searchedMovies: [MovieRepresentation] = []
    
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
    func fetchMovies(completion: @escaping CompletionHandler = { _ in}) {
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("error")
                completion(error)
                return
            }
            guard let data = data else {
                NSLog("No data returned from fetch")
                completion(NSError())
                return
            }
                do {
                    let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                    try self.updateMovies(with: movieRepresentations)
                    completion(nil)
                } catch {
                    print("Error decoding movie representations: \(error)")
                    completion(error)
                    return
                }
        
    }.resume()
}
    
    func updateMovies(with representations: [MovieRepresentation]) {
        let entriesWithID = representations.filter({ $0.identifier != nil })

        let identifiersToFetch = entriesWithID.compactMap { ($0.identifier) }
        let representationByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, entriesWithID))

        var entriesToCreate = representationByID
        
            let context = CoreDataStack.shared.mainContext
            let fetchRequest: NSFetchRequest<Movies> = Movies.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        }

        

        let context = CoreDataStack.shared.container.newBackgroundContext()

        guard let representation = representationByID[identifier] else { return }
        self.update(entry: entry, with: representation)

        entriesToCreate.removeValue(forKey: identifier)
    }

    
    // Saves content to Core Data
    func save() {
        let moc = CoreDataStack.shared.mainContext
        do {
            try? moc.save()
        } catch {
            print("Error Saving: \(error)")
        }
    }
    
    func put(movies: Movies, completion: @escaping () -> Void = { }) {
        let uuid = movies.identifier ?? ""
        let requestURL = baseURL.appendingPathComponent(uuid).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var representation = movies.movieRepresentation else {
                completion()
                return
            }
            
            representation.identifier = uuid
            movies.identifier = uuid
            try save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error Encoding Movies: \(error)")
            completion()
            return
        }
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
              print("There was an error with the DataTask: \(error)")
                completion()
                return
            }
            completion()
        }.resume()
    }
    
    func createMovie(with movie: title, String, identifier: String?, hasWatched: Bool?, context: NSManagedObject) {
        let movie = MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
        CoreDataStack.shared.save()
        put(movies: movie)
    }
    
    // MARK: - Properties
    
    

