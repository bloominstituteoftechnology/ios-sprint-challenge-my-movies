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
    
    enum HTTPMethod: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }
    
    typealias CompletionHandler = (Error?) -> Void
    
    init() {
        fetchMoviesFromServer()
    }
    
    // MARK: - Properties

    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let serverBaseURL = URL(string: "https://mymovies-713ca.firebaseio.com/")!
        
    var searchedMovies: [MovieRepresentation] = []
    
    // MARK: - Public Search Method
    
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
    
    // MARK: - Public CRUD Methods
    
    // Create Movie
    func createMovie(title: String, hasWatched: Bool, identifier: UUID) {
        let movie = Movie(title: title, identifier: identifier, hasWatched: hasWatched)
        putMovieToServer(movie)
    }

    func createMovie(from movieRepresentation: MovieRepresentation) {
        let title = movieRepresentation.title
        let identifier = movieRepresentation.identifier ?? UUID()
        let hasWatched = movieRepresentation.hasWatched ?? false
        createMovie(title: title, hasWatched: hasWatched, identifier: identifier)
    }
    
    // Update Movie
    func toggleHasWatched(for movie: Movie) {
        movie.hasWatched.toggle()
        putMovieToServer(movie)
    }
    
    // Delete Movie
    func deleteMovie(_ movie: Movie) {
        deleteMovieFromServer(movie) { (error) in
            guard error == nil else {
                print("Error deleting movie from server: \(error!)")
                return
            }
            
            guard let moc = movie.managedObjectContext else { return }
            
            moc.perform {
                do {
                    moc.delete(movie)
                    try CoreDataStack.shared.save(context: moc)
                } catch {
                    moc.reset()
                    print("Error deleting movie from managed object context: \(error)")
                }
            }
        }
    }

    // MARK: - Public Server API Methods

    // FETCH movies from server
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in  }) {
        let requestURL = serverBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            guard error == nil else {
                print("Error fetching movies from server: \(error!)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            guard let data = data else {
                print("No data returned by data task.")
                DispatchQueue.main.async {
                    completion(NSError())
                }
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                try self.updateMovies(with: movieRepresentations)
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                print("Error decoding movie representations: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }.resume()
    }
    
    
    // PUT movie to server
    private func putMovieToServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let moc = movie.managedObjectContext else { return }
        
        var uuidString = ""
        
        moc.perform {
            uuidString = movie.identifier?.uuidString ?? UUID().uuidString
        }
        
        let requestURL = serverBaseURL.appendingPathComponent(uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
                
        moc.perform {
            do {
                guard let representation = movie.movieRepresentation else {
                    completion(NSError())
                    return
                }
                
                //let identifier = UUID(uuidString: uuidString)
                //representation.identifier = identifier
                //movie.identifier = identifier
                try CoreDataStack.shared.save()
                request.httpBody = try JSONEncoder().encode(representation)
            } catch {
                print("Error encoding movie: \(error)")
                completion(error)
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard error == nil else {
                print("Error PUTting movie to server: \(error!)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    // DELETE movie from server
    private func deleteMovieFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let moc = movie.managedObjectContext else { return }
        
        moc.perform {
            guard let uuidString = movie.identifier?.uuidString else {
                completion(NSError())
                return
            }
            
            let requestURL = self.serverBaseURL.appendingPathComponent(uuidString).appendingPathExtension("json")
            var request = URLRequest(url: requestURL)
            request.httpMethod = HTTPMethod.delete.rawValue
            
            URLSession.shared.dataTask(with: request) { (_, _, error) in
                guard error == nil else {
                    print("Error deleting movie: \(error!)")
                    DispatchQueue.main.async {
                        completion(error)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            }.resume()
        }
    }
    
    // MARK: - Private Methods

    private func updateMovies(with representations: [MovieRepresentation]) throws {
        let representationsWithID = representations.filter { $0.identifier != nil }
        let identifiersToFetch = representationsWithID.compactMap { $0.identifier! }
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representationsWithID))
        var moviesToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.perform {
            do {
                // Delete existing movies not found in server database
                let allExistingMovies = try context.fetch(Movie.fetchRequest()) as? [Movie]
                let moviesToDelete = allExistingMovies!.filter { !identifiersToFetch.contains($0.identifier!) }
                
                for movie in moviesToDelete {
                    context.delete(movie)
                }
                
                // Update existing movies found in server database
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else { continue }
                    
                    self.update(movie: movie, with: representation)
                    moviesToCreate.removeValue(forKey: id)
                }
                
                // Create new movies found in server database
                for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
            } catch {
                print("Error fetching movies for UUIDs: \(error)")
            }
        }
        
        try CoreDataStack.shared.save(context: context)
    }
    
    private func update(movie: Movie, with movieRepresentation: MovieRepresentation) {
        movie.title = movieRepresentation.title
        movie.hasWatched = movieRepresentation.hasWatched ?? false
        movie.identifier = movieRepresentation.identifier
    }
}
