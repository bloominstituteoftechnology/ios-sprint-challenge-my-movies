//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

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
        fetchMoviesFromServer()
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
            /// Convert our movie object into something we can send to Firebase.
            guard var representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
// FIXME: Can't set due to identifier being let            representation.identifier = uuid
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
    
    /// Grab all the movies from Firebase to make sure we're in sync.
    /// - Parameter representations: MovieRepresentation objects that are fetched from Firebase
    private func updateMovies(with representations: [MovieRepresentation]) throws {
        
        /// Create a fetch request from Movie object.
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()

        /// Create a dictionary with the identifiers of the representations as the keys, and the values as the representations. To accomplish making this dictionary you will need to create a separate array of just the movie representations identifiers. You can use the zip method to combine two arrays of items together into a dictionary.
        let moviesByID = representations.filter { $0.identifier != nil }
        let identifiersToFetch = moviesByID.compactMap { $0.identifier }
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesByID))
        var moviesToCreate = representationsByID

        /// Give the fetch request an NSPredicate. This predicate should see if the identifier attribute in the Movie is in identifiers array that you made from the previous step. Refer to the hint below if you need help with the predicate.
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)

        /// Perform the fetch request on your core data stack's mainContext.
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            do {
                /// This will return an array of Movie objects whose identifier was in the array you passed in to the predicate.
                let existingMovies = try context.fetch(fetchRequest)
                
                /// Loop through the fetched movies and call update. Then remove the movie from the dictionary. Afterwards we'll create movies from the remaining objects in the dictionary. The only ones that would remain after this loop are ones that didn't exist in Core Data already.
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else { continue }
                    self.update(movie: movie, with: representation)
                    moviesToCreate.removeValue(forKey: id)
                }
                
                /// Create an movie for each of the values in moviesToCreate using the Movie initializer that takes in an MovieRepresentation and an NSManagedObjectContext
                for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }

                // TODO: ? This isn't under both loops. Concerned about saving too much
                /// Under both loops, call saveToPersistentStore() to persist the changes and effectively synchronize the data in the device's persistent store with the data on the server. Since you are using an NSFetchedResultsController, as soon as you save the managed object context, the fetched results controller will observe those changes and automatically update the table view with the updated movies.
                try context.save() // Caller will handle

            } catch {
                /// Make sure you handle a potential error from the fetch method on your managed object context, as it is a throwing method.
                NSLog("Error fetching movies for UUIDs: \(error)")
            }
        }
    }

    private func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = firebaseBaseURL.appendingPathExtension("json")
        
        // TODO: ? Where is the GET specified? Default?
        URLSession.shared.dataTask(with: requestURL) { data, _, error in
            /// Did the call complete without error?
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion(error)
                return
            }
            
            /// Did we get anything?
            guard let data = data else {
                NSLog("No data returned by data task")
                completion(NSError()) // Convert to ResultType
                return
            }
            
            /// Unwrap the data returned in the closure.
            do {
                var movieRepresentation: [MovieRepresentation] = []
                movieRepresentation = Array(try JSONDecoder().decode([String: MovieRepresentation].self,
                                                                      from: data).values)
                try self.updateMovies(with: movieRepresentation)
                completion(nil)

            } catch {
                NSLog("Error decoding or saving data from Firebase: \(error)")
                completion(error)
            }
        }.resume()
    }
    
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

    private func update(movie: Movie, with representation: MovieRepresentation) {
        //movie.identifier = representation.identifier
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched ?? false
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
                NSLog("Error DELETEing movie from server \(error)")
                completion(error)
                return
            }

            completion(nil)
        }.resume()
    }
}
