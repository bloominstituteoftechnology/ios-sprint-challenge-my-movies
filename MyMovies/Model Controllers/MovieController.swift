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
    
    // MARK: - Initializer
    
    init() {
        fetchMoviesFromServer()
    }
    
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
    
    private let fireURL = URL(string: "https://mymovies-77687.firebaseio.com/")!
    typealias CompletionHandler = (Error?) -> Void
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = {_ in }) {
        let requestURL = fireURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { data, _, error in
            if let error = error {
                NSLog("Error fetching tasks : \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No Data returned by data task")
                completion(NSError())
                return
            }
            
//            var represent: [MovieRepresentation] = []
            
            do {
                let represent = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                try self.updateMovies(with: represent)
                completion(nil)
            } catch {
                NSLog("Error decoding fetched data into core data: \(error)")
                completion(error)
            }
        }.resume()
        
    }
    
    func updateMovies(with representations: [MovieRepresentation]) throws {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        
        let onlyIdentifiers = representations.map { $0.identifier }
        
        var orderByID = Dictionary(uniqueKeysWithValues: zip(onlyIdentifiers, representations))
        
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", onlyIdentifiers)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            do {
                
                // Get all existing movies with the received UUIDs from firebase. Loop through them to update them, and then remove them from our received array.
                
                let existingMovies = try context.fetch(fetchRequest)
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = orderByID[id] else { return }
                    update(movie: movie, representation: representation)
                    orderByID.removeValue(forKey: id)
                }
                
                // For any movies left in our received array's values, add them to our CoreData
                for representation in orderByID.values {
                    Movie(representation: representation, context: context)
                }
                
            } catch {
                NSLog("Error syncin database's entries with coreData \(error)")
                return
            }
        }
        try CoreDataStack.shared.save(context: context)
    }
    
    func sendMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = fireURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movie.movieRepresentation)
        } catch {
            NSLog("Error encoding data and assigning it to httpBody")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                NSLog("Error initiating request after encoding data : \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
        
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = fireURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                NSLog("Error ideleteing movie from server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
        
    }
    
    // MARK: - Core Data
    
    // Create
    func create(title: String) {
        let movie = Movie(identifier: UUID(), title: title, hasWatched: false, context: CoreDataStack.shared.mainContext)
        sendMovieToServer(movie: movie)
        saveToPersistentStore()
    }
    
    func delete(at movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        deleteMovieFromServer(movie: movie)
        saveToPersistentStore()
    }
    
    func update(movie: Movie, representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched ?? false
    }
    
    func toggleWatch(for movie: Movie) {
        movie.hasWatched.toggle()
        sendMovieToServer(movie: movie)
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
                if let _ = existingMovies.firstIndex(where: {$0.title == representation.title}) {
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
