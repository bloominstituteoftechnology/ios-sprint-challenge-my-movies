//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethods: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
}

class MovieController {
    
    init() {
        self.fetchMoviesFromServer()
    }
    
    // MARK: - FireBase URL
    
    let fireBaseURL = URL(string: "https://mymoviessprintchallenge.firebaseio.com/")!
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    // MARK: - API
    
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
}

extension MovieController {
    
    
    // MARK: - Firebase
    
    typealias CompletionHandler = (Error?) -> Void
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in} ) {
        let requestURL = fireBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching Movies: \(error)")
                completion(error)
                return
            }
            guard let data = data else {
                NSLog("No data returned from the data task")
                completion(error)
                return
            }
            do {
                let movieReps = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                let moc = CoreDataStack.shared.mainContext
                try self.updateMovies(representations: movieReps, context: moc)
                completion(nil)
            } catch {
                NSLog("Error decoding movie representations")
                completion(error)
                return
            }
        }.resume()
    }
    
    
    private func updateMovies(representations: [MovieRepresentation], context: NSManagedObjectContext) throws {
        var error: Error? = nil
        
        context.performAndWait {
            for movieRep in representations {
                if let identifier = movieRep.identifier {
                    if let movie = self.fetchSingleMovieFromPersistentStore(forUUID: identifier.uuidString, in: context) {
                        self.update(movie: movie, representation: movieRep, context: context)
                    } else {
                        let _ = Movie(movieRep: movieRep, context: context)
                    }
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
    
    private func fetchSingleMovieFromPersistentStore(forUUID uuid: String, in context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid)
        
        var result: Movie? = nil
        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching movie with UUID: \(uuid) \(error)")
            }
        }
        return result
    }
    
    func createMovie(title: String) {
        let movie = Movie(title: title)
        
        do {
            try CoreDataStack.shared.save()
            self.put(movie: movie)
        } catch {
            NSLog("Error creating a movie: \(movie)")
        }
    }
    
    func updateMovie(movie: Movie, title: String) {
        movie.title = title
        do {
            try CoreDataStack.shared.save()
            self.put(movie: movie)
        } catch {
            NSLog("Error updating movie: \(movie)")
        }
    }
    
    
    // MARK: - Updating the Movie with MovieRep from the server
    
    private func update(movie: Movie, representation: MovieRepresentation, context: NSManagedObjectContext) {
        movie.title = representation.title
    }
    
    func updateHasWatched(movie: Movie) {
        movie.hasWatched.toggle()
        do {
            try CoreDataStack.shared.save()
            self.put(movie: movie)
        } catch {
            NSLog("Error updating movie: \(movie)")
        }
    }
    
    func deleteMovie(movie: Movie) {
        self.deleteMovieFromServer(movie: movie) { (error) in
            if let error = error {
                NSLog("Error deleting movie from server: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                let moc = CoreDataStack.shared.mainContext
                moc.delete(movie)
                
                do {
                    try moc.save()
                } catch {
                    NSLog("Error saving after delete method")
                }
            }
        }
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = fireBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethods.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            print(response!)
            completion(error)
        }.resume()
    }
    
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = fireBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethods.put.rawValue
        
        
        guard var representation = movie.movieReprensentation else { completion(NSError()); return }
        
        do {
            representation.identifier = uuid // is this needed?
            movie.identifier = uuid
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error ecoding movie: \(movie) \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting to the server")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
        
    }
    
    
}
