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
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

class MovieController {
    
    init() {
        fetchMoviesFromServer()
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    let firebaseURL = URL(string: "https://mymovies-2d3de.firebaseio.com/")!
    
    
    // MARK: - Methods
    
    func saveMovie(with title: String, identifier: UUID, hasWatched: Bool = false) -> Movie {
        let movie = Movie(title: title, identifier: identifier, hasWatched: hasWatched, context: CoreDataStack.shared.mainContext)
        saveToPersistentStore()
        put(movie: movie)
        return movie
    }
    
    func delete(movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        saveToPersistentStore()
    }
    
    func put(movie: Movie, completion: @escaping (Error?) -> Void = {_ in }) {
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard let movieRepresentation = movie.movieRepresentation else {
            print("Movie representation is nil")
            completion(NSError())
            return
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            print("Error encoding movie representation: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("Error PUTing movie: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
        saveToPersistentStore()
    }
    
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void = { _ in } ) {
        let requestURL = firebaseURL.appendingPathExtension(".json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error fetching movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                print("No data returned")
                completion(error)
                return
            }
            
            do {
                let movieRepresentation = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                
                try self.updateMovies(with: movieRepresentation)
                completion(nil)
            } catch {
                print("Error decoding movie representation")
                completion(error)
                return
            }
        }
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping (Error?) -> Void) {
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            print("Deleted task with UUID: \(uuid.uuidString)")
            completion(error)
        }.resume()
    }
    
    private func updateMovies(with representations: [MovieRepresentation]) throws {
            let tasksWithID = representations.filter({ $0.identifier != nil })
            
            let identifiersToFetch = tasksWithID.compactMap({ $0.identifier })
            
            // Creating a dictionary of TaskRepresentation objects keyed by UUID
            let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, tasksWithID))
            
            // Running log of all the tasks we need to do something with (either update existing tasks or create new ones)
            var tasksToCreate = representationsByID
            
            // Fetch the objects from CoreData that have a UUID contained in the identifiersToFetch array
            let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "uuid IN %@", identifiersToFetch)
            
            let context = CoreDataStack.shared.container.newBackgroundContext()
            
            context.perform {
                do {
                    let existingMovies = try context.fetch(fetchRequest)
                    
                    // Updating existing Tasks
                    for movie in existingMovies {
                        guard let id = movie.identifier,
                            let representation = representationsByID[id] else {
                                continue
                        }
                        self.update(movie: movie, with: representation)
                        
                        // Remove the object that we just updated from our running log
                        tasksToCreate.removeValue(forKey: id)
                    }
                    
                    // Create new Tasks for all remaining server Tasks
                    for representation in tasksToCreate.values {
                        let _ = Movie(movieRepresentation: representation, context: context)
                    }
                } catch {
                    print("Error fetching tasks for UUIDs: \(error)")
                }
            }
            
            try CoreDataStack.shared.save(context: context)
        }
    
    func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched!
        
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
    
    func saveToPersistentStore() {
        CoreDataStack.shared.saveToPersistentStore()
    }
    
    
}
