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
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://my-movies-db27d.firebaseio.com/")!
    
    func saveToPersistentStore() {
        let moc = CoreDataStack.shared.mainContext
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            moc.reset()
            print("Error saving moc: \(error)")
        }
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
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    typealias CompletionHandler = (Error?) -> Void
    
    // MARK: Functions
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var representation = movie.movieRepresentation else {
                completion(nil)
                return
            }
            
            representation.identifier = uuid.uuidString
            movie.identifier = uuid
            
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error sending task or saving to persistent store: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (ata, _, error) in
            if let error = error {
                print("Error PUTting movie on firebase: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    func fetchMovieListFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let baseURL = firebaseURL.appendingPathExtension("json")
        let requestURL = URLRequest(url: baseURL)
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error fetching movie list: \(error)")
                completion(error)
            }
            
            guard let data = data else {
                print("Error getting data")
                completion(error)
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let movieRepresentation = try jsonDecoder.decode([String: MovieRepresentation].self, from: data).map( { $0.value } )
                let moc = CoreDataStack.shared.container.newBackgroundContext()
                
                self.checkMovieRepresentation(movieRepresentations: movieRepresentation, context: moc)
                completion(nil)
            } catch {
                print("Error decoding movie: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    func updateMovieRep(movie: Movie, movieRepresentation: MovieRepresentation) {
        guard let identifierString = movieRepresentation.identifier,
            let identifier = UUID(uuidString: identifierString) else { return }
        movie.identifier = identifier
        movie.title = movieRepresentation.title
        movie.hasWatched = movieRepresentation.hasWatched ?? false
        
    }
    
    func checkMovieRepresentation(movieRepresentations: [MovieRepresentation], context: NSManagedObjectContext) {
        
        context.performAndWait {
            for movieRepresentation in movieRepresentations {
                if let identifier = movieRepresentation.identifier, let movie = self.fetchMovieFromPersistentStore(identifier: identifier, context: context) {
                    self.updateMovieRep(movie: movie, movieRepresentation: movieRepresentation)
                } else {
                    _ = Movie(movieRepresentation: movieRepresentation, context: context)
                }
            }
            
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    func fetchMovieFromPersistentStore(identifier: String, context: NSManagedObjectContext) -> Movie? {
        let fetchMovieRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchMovieRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        
        var movie: Movie?
        context.performAndWait {
            do {
                movie = try context.fetch(fetchMovieRequest).first
            } catch {
                print("Error fetching movie \(identifier) with error: \(error)")
            }
        }
        return movie
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let identifierString = movie.identifier?.uuidString
        guard let identifier = identifierString else { return }
        
        
        let url = firebaseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var requestURL = URLRequest(url: url)
        requestURL.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error PUTting movie to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    // MARK: CRUD Methods
    
    func create(title: String) {
        let movie = Movie(title: title)
        put(movie: movie)
        saveToPersistentStore()
    }
    
    func update(movie: Movie) {
        movie.hasWatched.toggle()
        put(movie: movie)
    }
    
    func delete(movie: Movie) {
        deleteMovieFromServer(movie: movie)
        CoreDataStack.shared.mainContext.delete(movie)
        saveToPersistentStore()
    }
    
}


