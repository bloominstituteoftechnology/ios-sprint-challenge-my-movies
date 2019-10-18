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

enum NetworkingError: Error {
    case representationNil
    case encodingError
    case decodingError
    case putError
    case deleteError
    case fetchError
    case noData
}

class MovieController {
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://ios-movie-watch-list.firebaseio.com/")!
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
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
    
    func createMovie(title: String, context: NSManagedObjectContext) {
        
        let movie = Movie(title: title, context: context)
        put(movie: movie) { (error) in
            if error == nil {
                CoreDataStack.shared.save(context: context)
            }
        }
    }
    
    func updateMovie(movie: Movie, hasWatched: Bool, context: NSManagedObjectContext) {
        movie.hasWatched = hasWatched
        put(movie: movie) { (error) in
            if error == nil {
                CoreDataStack.shared.save(context: context)
            }
        }
    }
    
    func deleteMovie(movie: Movie, context: NSManagedObjectContext) {
        context.performAndWait {
            deleteFromServer(movie: movie) { (error) in
                if error == nil {
                    context.delete(movie)
                    CoreDataStack.shared.save(context: context)
                }
            }
        }
    }
    
    func update(movie: Movie, representation: MovieRepresentation) {
        movie.title = representation.title
        movie.identifier = representation.identifier
        movie.hasWatched = representation.hasWatched!
    }
    
    func fetchMoviesFromServer(completion: @escaping (NetworkingError?) -> Void = { _ in }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        let request = URLRequest(url: requestURL)
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion(.fetchError)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from entry fetch data task")
                completion(.noData)
                return
            }
            
            do {
                let movies = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({ $0.value })
                self.updateMovies(with: movies)
            } catch {
                NSLog("Error decoding MovieRepresentation: \(error)")
                completion(.decodingError)
            }
            completion(nil)
        }.resume()
    }
    
    func updateMovies(with representations: [MovieRepresentation]) {
        let identifiersToFetch = representations.map({ $0.identifier })
        let representationByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var movieToCreate = representationByID
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.performAndWait {
            do {
                let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let identifier = movie.identifier, let representation = representationByID[identifier] else { continue }
                    update(movie: movie, representation: representation)
                    movieToCreate.removeValue(forKey: identifier)
                }
                
                for representation in movieToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
                
                CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error fetching movies from persistent store: \(error)")
            }
        }
    }
    
    
    func put(movie: Movie, completion: @escaping (NetworkingError?) -> Void = { _ in }) {
        
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard let movieRepresentation = movie.movieRepresentation else {
            NSLog("Movie Representation is nil")
            completion(.representationNil)
            return
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            NSLog("Error encoding Movie Representation: \(error)")
            completion(.encodingError)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTting movie: \(error)")
                completion(.putError)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func deleteFromServer(movie: Movie, completion: @escaping (NetworkingError?) -> Void = { _ in }) {
        
        guard let identifier = movie.identifier else {
            NSLog("No identifier found")
            completion(.deleteError)
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error DELETING entry \(error)")
                completion(.deleteError)
            }
        completion(nil)
        }.resume()
        
    }
}
