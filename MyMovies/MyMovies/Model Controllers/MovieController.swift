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
    
    typealias CompletionHandler = (Error?) -> Void
    let fireBaseURL = URL(string: "https://movies-f05dc.firebaseio.com/")!
    
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
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = fireBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion(NSError())
                return
            }
            
            guard let data = data else {
                NSLog("No data returned by data movie")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                let moc = CoreDataStack.shared.container.newBackgroundContext()
                try self.updateMovies(with: movieRepresentations, context: moc)
                completion(nil)
            } catch {
                NSLog("Error decoding entry representations: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        let uuid = movie.identifier ?? UUID()
        movie.identifier = uuid
        
        let requestURL = fireBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            
            let representation = movie.movieRepresentation
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTing movie to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    private func updateMovies(with representations: [MovieRepresentation], context: NSManagedObjectContext) throws {
        var error: Error? = nil
        context.performAndWait {
            for movieRep in representations {
                guard let identifier = movieRep.identifier else { continue }
                
                if let movie = self.movie(forUUID: identifier, in: context) {
                    self.update(movie: movie, with: movieRep)
                } else {
                    let _ = Movie(movieRepresentation: movieRep, context: context)
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
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        
        let requestURL = fireBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
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
    
    private func movie(forUUID uuid: UUID, in context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        
        var results: Movie? = nil
        context.performAndWait {
            do {
                results = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching movie with uuid \(uuid): \(error)")
            }
        }
        return results
    }
    
    func createMovie(movie title: String, identifier: UUID) {
        let movie = Movie(title: title, identifier: identifier)
        put(movie: movie)
        saveToPersistantStore()
    }
    
     func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.identifier = representation.identifier
        movie.hasWatched = representation.hasWatched!
        
        put(movie: movie)
    }
    
    func updateMovie(movie: Movie) {
        put(movie: movie)
        saveToPersistantStore()
    }
    
    func delete(movie: Movie) {
        deleteMovieFromServer(movie: movie)
        
        if let moc = movie.managedObjectContext {
            moc.delete(movie)
            saveToPersistantStore()
        }
    }
    
    func toggleWatched(movie: Movie, hasWatched: Bool) {
        movie.hasWatched = !movie.hasWatched
        put(movie: movie)
    }
    
    func saveToPersistantStore() {
        let moc = CoreDataStack.shared.mainContext
        do {
            try moc.save()
        } catch {
            NSLog("Error saving manged object context: \(error)")
        }
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
