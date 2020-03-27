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
    
    typealias CompletionHandler = (Error?) -> Void
    
    let firebaseURL = URL(string: "https://week7-eca3c.firebaseio.com/")!
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
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        print("OK IT SHOULD BE PUTTING")
        let uuid = movie.identifier ?? UUID()
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var representation = movie.movieRepresentation else {
                
                completion(NSError())
                return
            }

            representation.identifier = uuid
            movie.identifier = uuid
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding/saving entry: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            print("something should happen")
            if let error = error {
                NSLog("Error PUTting entry to server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        print("IT IS FETCHING")
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { data, _, error in
            if let error = error {
                NSLog("Error fetching entries: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned by data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                try self.updateEntries(with: movieRepresentations)
            } catch {
                NSLog("Error decoding or saving data from Firebase: \(error)")
                completion(error)
            }
        }.resume()
        
    }
    
    func deleteEntryFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        print("IT SHOULD BE DELETING")
        let uuid = movie.identifier ?? UUID()
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                NSLog("Error deleting entry from server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    private func updateEntries(with representations: [MovieRepresentation]) throws {
         let moviesByID = representations.filter { $0.identifier != nil}
        let identifiersToFetch = moviesByID.compactMap { $0.identifier }
         let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesByID))
         var movieToCreate = representationsByID
         
         let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
         fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
         
        let context = CoreDataStack.shared.container.newBackgroundContext()
         
        context.performAndWait {
            do {
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else {continue}
                    self.update(movie: movie, with: representation)
                    movieToCreate.removeValue(forKey: id)
                }
                
                for representation in movieToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
            } catch {
                NSLog("Error fetching entries for UUIDs: \(error)")
            }
        }
        
        try CoreDataStack.shared.save(context: context)
     }
    
    func updater(movie: Movie) {
        movie.hasWatched.toggle()
        put(movie: movie)
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched ?? false
        movie.identifier = representation.identifier
    }
    
    func create(title: String) {
        let movie = Movie(identifier: UUID(), title: title, hasWatched: false, context: CoreDataStack.shared.mainContext)
        put(movie: movie)
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    func delete(movie: Movie) {
        
        CoreDataStack.shared.mainContext.delete(movie)
        deleteEntryFromServer(movie: movie)
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
}
