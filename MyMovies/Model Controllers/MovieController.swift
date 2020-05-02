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
    
    init() {
        fetchMoviesFromServer()
    }
    
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
        
    var searchedMovies: [MovieRepresentation] = []
    
    typealias CompletionHandler = (Error?) -> Void
    
    let firebaseURL = URL(string: "https://mymovies-b1914.firebaseio.com/")!
    
    
    // MARK: - Firebase methods
    
    func sendMovieToFirebase(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let identifier = movie.identifier ?? UUID()
        let fetchRequest = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var urlRequest = URLRequest(url: fetchRequest)
        urlRequest.httpMethod = "PUT"
        
        do {
            guard let representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            
            try CoreDataStack.shared.save()
            urlRequest.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error saving context or encoding movie representation: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { _, _, error in
            if let error = error {
                NSLog("Error sending (PUT) movie to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let identifier = movie.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async {
                completion(error)
            }
        }.resume()
    }
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { data, _, error in
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned by data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                try self.updateMovies(with: movieRepresentations)
                completion(nil)
            } catch {
                NSLog("Error decoding or saving data from Firebase: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    // MARK: - Core Data methods
    
    func createMovie(title: String,
                     identifier: UUID,
                     hasWatched: Bool,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let newMovie = Movie(title: title,
                             identifier: identifier,
                             hasWatched: hasWatched)
        context.insert(newMovie)
        sendMovieToFirebase(movie: newMovie)
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving movie to core data")
        }
    }
    
    func deleteMovie(movie: Movie,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.delete(movie)
        deleteMovieFromServer(movie)
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error deleting movie from core data")
        }
    }
    
    private func updateMovies(with representations: [MovieRepresentation]) throws {
        let moviesByID = representations.filter { $0.identifier != nil }
        let identifiersToFetch = moviesByID.compactMap { $0.identifier }
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesByID))
        var moviesToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            do {
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else { continue }
                    self.update(movie: movie, with: representation)
                    moviesToCreate.removeValue(forKey: id)
                }
                
                for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
            } catch {
                NSLog("Error fetching movies for UUIDs: \(error)")
            }
        }
        
        try CoreDataStack.shared.save(context: context)
    }
    
    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched ?? false
    }
    
}
