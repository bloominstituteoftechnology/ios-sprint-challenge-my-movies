//
//  SavedMoviesController.swift
//  MyMovies
//
//  Created by Eoin Lavery on 14/10/2019.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class SavedMoviesController {
    
    //MARK: - PROPERTIES
    //A static instance of this class to have a single accessible instance available throughout the app.
    static let shared = SavedMoviesController()
    let baseURL = URL(string: "https://mymoviessc.firebaseio.com/")
    
    //MARK: - FUNCTIONS FOR LOCAL STORAGE
    func toggleHasWatched(for movie: Movie) {
        do {
            movie.hasWatched.toggle()
            try CoreDataStack.shared.save()
        } catch {
            print("Error updating hasWatched value for movie '\(movie.title ?? "blank movie")': \(error)")
        }
        
        put(movie: movie)
    }
    
    func addMovie(for representation: MovieRepresentation) {
        guard let newMovie = Movie(movieRepresentation: representation) else { return }
        put(movie: newMovie)
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error saving new movie to local storage: \(error)")
        }
    }
    
    func deleteMovie(for movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        CoreDataStack.shared.mainContext.delete(movie)
        deleteMovieFromServer(movie: movie)

        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error deleting movie from local storage: \(error)")
            CoreDataStack.shared.mainContext.reset()
        }
        
        completion(nil)
    }
    
    func updateMovie(movie: Movie, with representation: MovieRepresentation) {
        guard let hasWatched = representation.hasWatched else { return }
        movie.title = representation.title
        movie.hasWatched = hasWatched
    }
    
    func fetchMoviesToTableView(for representations: [MovieRepresentation]) throws {
        let moviesWithIdentifier = representations.filter({ $0.identifier != nil })
        let identifiersToFetch = moviesWithIdentifier.compactMap({ $0.identifier })
        let representationsByIdentifier = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithIdentifier))
        var movies = representationsByIdentifier
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let identifiersPredicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        fetchRequest.predicate = identifiersPredicate
        
        let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
        backgroundContext.perform {
            do {
                let presentMovies = try backgroundContext.fetch(fetchRequest)
                
                for movie in presentMovies {
                    guard let identifier = movie.identifier, let representation = representationsByIdentifier[identifier] else { continue }
                    self.updateMovie(movie: movie, with: representation)
                    movies.removeValue(forKey: identifier)
                }
                
                for representation in movies.values {
                    let _ = Movie(movieRepresentation: representation, context: backgroundContext)
                }
                
            } catch {
                print("Error fetching movie with identifier: \(error)")
            }
        }
        try CoreDataStack.shared.save(context: backgroundContext)
    }
    
    //MARK: - FUNCTIONS FOR ONLINE STORAGE
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        guard let baseURL = baseURL else { return }
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error fetching movies from server: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                print("No data returned from server")
                completion(nil)
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let moviesDict = try jsonDecoder.decode([String: MovieRepresentation].self, from: data)
                let movieRepresentations = Array(moviesDict.values)
                try self.fetchMoviesToTableView(for: movieRepresentations)
            } catch {
                print("Error decoding data from server: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    func put(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        
        guard let baseURL = baseURL else { return }
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var representation = movie.movieRepresentation else { completion(nil); return }
            representation.identifier = uuid
            movie.identifier = uuid
            try CoreDataStack.shared.save()
            let jsonEncoder = JSONEncoder()
            request.httpBody = try jsonEncoder.encode(representation)
        } catch {
            print("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("Error saving movie to online server: \(error)")
                completion(error)
                return
            }
        }.resume()
        completion(nil)
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        guard let uuid = movie.identifier else { completion(nil); return }
        
        guard let baseURL = baseURL else { return }
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("Error deleting movie from online server: \(error)")
                completion(nil)
                return
            }
            completion(nil)
        }.resume()
    }
    
}
