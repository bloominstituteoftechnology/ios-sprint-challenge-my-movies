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
    
    // MARK: - Properties
    var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseUrl = URL(string: "https://mymoviesproj.firebaseio.com/")!
    
    //Initialisers
    init() {
        fetchMovies()
    }
    
    //MARK: - Public Functions
    func movieWasWatched(movie: Movie) {
        movie.hasWatched.toggle()
        
        do {
            try CoreDataStack.shared.save()
            put(movie: movie)
        } catch {
            print("Error updating movie hasWatched property: \(error)")
        }
    }
    
    func saveMovie(movieRepresentation: MovieRepresentation) {
        guard let movie = Movie(movieRepresentation: movieRepresentation) else { return }
        
        do {
            try CoreDataStack.shared.save()
            put(movie: movie)
        } catch {
            print("Error saving movie: \(error)")
        }
    }
    
    func findMovie(uuid: UUID, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        
        var searchResult: Movie? = nil
        context.performAndWait {
            do {
                searchResult = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error finding movie: \(error)")
            }
        }
        return searchResult
    }
    
    func put(movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        guard let identifier = movie.identifier,
            let movieRepresentation = movie.movieRepresentation else {
                completion(NSError())
                return
        }
        
        let requestUrl = firebaseUrl.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        let jsonEncoder = JSONEncoder()
        
        do {
            request.httpBody = try jsonEncoder.encode(movieRepresentation)
        } catch {
            print("Error PUTing Movie to Firebase: \(error)")
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    private func updateCoreDataMovies(movie: Movie, movieRepresentation: MovieRepresentation) {
        guard let hasWatched = movieRepresentation.hasWatched else {
            return
        }
        
        movie.hasWatched = hasWatched
        
        movie.identifier = movieRepresentation.identifier
        movie.title = movieRepresentation.title
    }
    
    private func updateMovies(movieRepresentations: [MovieRepresentation], context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        
        var error: Error?
    
        context.performAndWait {
            for movieRepresentation in movieRepresentations {
                if let movie = self.findMovie(uuid: movieRepresentation.identifier ?? UUID(), context: CoreDataStack.shared.mainContext) {
                    self.updateCoreDataMovies(movie: movie, movieRepresentation: movieRepresentation)
                } else {
                    let _ = Movie(movieRepresentation: movieRepresentation, context: context)
                }
            }
            
            do {
                try context.save()
            } catch let caughtError {
                error = caughtError
            }
        }
        
        if let error = error { throw error }
    }
    
    func fetchMovies(completion: @escaping ((Error?) -> Void) = { _ in }) {
        let requestURL = firebaseUrl.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error retrieving movies from server: \(error)")
                completion(error)
                return
            }

            guard let data = data else {
                print("Error accessing data retrieved from server: \(error!)")
                completion(nil)
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let movieRepresentations = try jsonDecoder.decode([String: MovieRepresentation].self, from: data).map({$0.value})
                
                try self.updateMovies(movieRepresentations: movieRepresentations, context: CoreDataStack.shared.container.newBackgroundContext())
                completion(nil)
            } catch {
                print("Error decoding data retrieved from server: \(error)")
                completion(error)
                return
            }
        }.resume()
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
    
    func deleteCoreDataMovie(movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        deleteMovieFromServer(movie: movie)
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error deleting movie from database: \(error)")
        }
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        guard let identifier = movie.identifier else {
            completion(nil)
            return
        }
        
        let requestURL = firebaseUrl.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error deleting movie from server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
}
