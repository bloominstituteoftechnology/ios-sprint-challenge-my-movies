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
    
    
    //init() { fetchMoviesFromServer() }
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
typealias CompletionHandler = (Error?) -> Void
    
    
    
    // MARK: - API Search
    
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
    
    
    
    
    // MARK: - CRUD
    
    func createMovie(title: String, identifier: UUID, hasWatched: Bool) {
        let movie = Movie(title: title, identifier: identifier, hasWatched: hasWatched)
        put(movie: movie)
    }
    
    func toggleWatched(movie: Movie, hasWatched: Bool) {
        movie.hasWatched = !movie.hasWatched
        put(movie: movie)
    }
    
    
    
    // MARK: - Server Functions
    
    let serverURL = URL(string: "https://mymovies-19800.firebaseio.com/")!
    
    
    
    func put(movie: Movie, completion: @escaping CompletionHandler = {_ in}) {
        
        let uuid = movie.identifier ?? UUID()
        
        let requestURL = serverURL
            .appendingPathComponent(uuid.uuidString)
            .appendingPathExtension("json")
        
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        
        do {
            guard let representation = movie.movieRepresentation else { throw NSError() }
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTTING movie to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = {_ in}) {
        
        let uuid = movie.identifier ?? UUID()
        
        let requestURL = serverURL
            .appendingPathComponent(uuid.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting movie: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    
    
    func fetchMoviesFromSever(completion: @escaping CompletionHandler = {_ in}) {
        
        let requestURL = serverURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
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
                let moc = CoreDataStack.shared.container.newBackgroundContext()
                try self.updateMovies(representations: movieRepresentations, context: moc)
                completion(nil)
            } catch {
                NSLog("Error decoding movie representations: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    
    func updateMovies(representations: [MovieRepresentation], context: NSManagedObjectContext) throws {
        
        var error: Error? = nil
        context.performAndWait {
            for movieRep in representations {
                guard let uuid = UUID(uuidString: movieRep.identifier!.uuidString) else { continue }
                
                if let movie = self.fetchSingleMovieFromPersistentStore(identifier: uuid.uuidString, context: context) {
                    self.update(movie: movie, movieRep: movieRep)
                } else {
                    let _ = Movie(movieRepresentation: movieRep)
                }
            }
            
            
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        if let error = error { throw error }
    }
    
    
    
    func update(movie: Movie, movieRep: MovieRepresentation) {
        movie.title = movieRep.title
        movie.identifier = movieRep.identifier
        movie.hasWatched = movieRep.hasWatched!
    }
    
    
    
    func fetchSingleMovieFromPersistentStore(identifier: String, context: NSManagedObjectContext) -> Movie? {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        
        var result: Movie? = nil
        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching movie with uuid: \(identifier): \(error)")
            }
        }
        return result
    }
}
