//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData
//MARK: - HTTPMethod Enum
enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

class MovieController {
    
    //MARK: - Variables
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://movies-6bc57.firebaseio.com/")!
    var searchedMovies: [MovieRepresentation] = []
    
    typealias CompletionHandler = (Error?) -> Void
    
    //MARK: - Functions
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        let queryParameters = ["query": searchTerm, "api_key": apiKey]
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
    
    //MARK: - Fetch Movie
    func fetchMovieFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movies from server: \(error)")
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentation = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                try self.updateMovies(with: movieRepresentation)
                completion(nil)
            } catch {
                NSLog("Error decoding entry: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    //MARK: - PUT Method
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let uuidString = ""
        let requestURL = firebaseURL.appendingPathComponent(uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        do {
            guard let representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting entry to server: \(error)")
                return
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    //MARK: - Delete From Server
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuidString = movie.identifier?.uuidString else {
            completion(NSError())
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting entry: \(error)")
                return
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    //MARK: - Update Method
    func updateMovies(with representations: [MovieRepresentation]) throws {
        let representationsWithID = representations.filter { $0.identifier != nil }
        let identifiersToFetch = representationsWithID.compactMap { $0.identifier! }
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representationsWithID))
        var moviesToCreate = representationsByID
        
        // Fetch all? entries from Core Data
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            do {
                let allExistingMovies = try context.fetch(Movie.fetchRequest()) as? [Movie]
                let moviesToDelete = allExistingMovies!.filter { !identifiersToFetch.contains($0.identifier!) }
                
                for movie in moviesToDelete {
                    context.delete(movie)
                }
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else { continue }
                    
                    self.update(movie: movie, movieRepresentation: representation)
                    moviesToCreate.removeValue(forKey: id)
                }
                for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
            } catch {
                print("Error fetching movies for UUIDs: \(error)")
            }
        }
        // Save all this in CoreData
        try CoreDataStack.shared.save(context: context)
    }
    
    //MARK: - CRUD Methods
    func createMovie(title: String, identifier: UUID, hasWatched: Bool) {
        let movie = Movie(title: title, identifier: identifier, hasWatched: hasWatched)
        put(movie: movie)
    }
    
    func create(movieRepresentation: MovieRepresentation) {
        let title = movieRepresentation.title
        guard let identifier = movieRepresentation.identifier, let hasWatched = movieRepresentation.hasWatched else { return }
        createMovie(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    func update(movie: Movie, movieRepresentation: MovieRepresentation) {
        movie.title = movieRepresentation.title
        movie.identifier = movieRepresentation.identifier
        movie.hasWatched = movieRepresentation.hasWatched ?? false
    }
    
    func toggleHasWatched(movie: Movie) {
        movie.hasWatched.toggle()
        put(movie: movie)
    }
    
    func deleteMovie(_ movie: Movie) {
        deleteMovieFromServer(movie: movie) { (error) in
            if let error = error {
                NSLog("error deleting entry: \(error)")
                return
            }
            guard let moc = movie.managedObjectContext else { return }
            moc.perform {
                do {
                    moc.delete(movie)
                    try CoreDataStack.shared.save(context: moc)
                } catch {
                    moc.reset()
                    NSLog("Error deleting entry: \(error)")
                }
            }
        }
    }
}
