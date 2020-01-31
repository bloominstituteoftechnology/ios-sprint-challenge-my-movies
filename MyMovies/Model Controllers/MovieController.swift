//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

// from my fire base realtime project
let fireBaseURL = URL(string: "https://mymovies-8d255.firebaseio.com/")!

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
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    typealias CompletionHandler = (Error?) -> Void
    
    init() {
        fetchMoviesFromServer()
    }
    
    // fetch from Firebase
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = fireBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error fetching movies: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            guard let data = data else {
                print("No data returned by data movie")
                DispatchQueue.main.async {
                    completion(NSError())
                }
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                try self.updateMovies(with: movieRepresentations)
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                print("Error decoding or storing movie representations: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
            }

            
            
        }.resume()
    }
    
    // convert FireBase objects to Core Data objects
    private func updateMovies(with representations: [MovieRepresentation]) throws {
        // filter out the no ID ones
        let moviesWithID = representations.filter { $0.identifier != nil }
        
        // creates a new UUID based on the identifier of the task we're looking at (and it exists)
        // compactMap returns an array after it transforms
        let identifiersToFetch = moviesWithID.compactMap { $0.identifier! }
        
        // zip interweaves elements
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
        
        var moviesToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        // in order to be a part of the results (will only pull tasks that have a duplicate from fire base)
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        // create private queue context
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.perform {
            do {
                let existingMovies = try context.fetch(fetchRequest)
                
                // updates local tasks with firebase tasks
                for movie in existingMovies {
                    // continue skips next iteration of for loop
                    guard let id = movie.identifier, let representation = representationsByID[id] else {continue}
                    self.update(movie: movie, with: representation)
                    moviesToCreate.removeValue(forKey: id)
                }
                
                for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
            } catch {
                print("Error fetching movies for UUIDs: \(error)")
            }
        }
        
        try CoreDataStack.shared.save(context: context)
    }
    
    // updates local with data from the remote (representation)
    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched!
    }
    
    // PUT when we make new tasks. Sends to firebase
    func sendMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier ?? UUID() // if it doesn't have one, make one
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT" // post ADDS to db (can add copies), "put" also finds recored and overrides it, or just adds
        
        // encode our data
        do {
            guard var representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            // both versions have same id
            representation.identifier = uuid
            movie.identifier = uuid
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding movie \(movie): \(error)")
            DispatchQueue.main.async {
                completion(error)
            }
            return
        }
        
        // ready to be sent to the database
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            // check for error
            if let error = error {
                print("error putting movie to server: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            // it works
            DispatchQueue.main.async {
                completion(nil)
            }
            
        }.resume()
    }
    
    // Delete from server if it can, then delete locally
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        // Needs to have ID
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json") // json type payload
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        // just for us to debug, want to if let error and if let response
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            print(response!) // 200 or error code
            
            DispatchQueue.main.async {
                completion(error)
            }
        }.resume()
    }
}
