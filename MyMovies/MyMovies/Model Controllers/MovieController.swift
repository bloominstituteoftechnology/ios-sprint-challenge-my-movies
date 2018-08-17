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
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    // MARK: - CRUD
    
    func create(movieRepresentation: MovieRepresentation) {
        guard let movie = Movie(movieRepresentation: movieRepresentation) else { return }
        
        putToServer(movie: movie)
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving to core data: \(error)")
        }
    }
    
    // dont need to update the movie's title
    func toggleWatched(movie: Movie) {
//    func update(movie: Movie, title: String, hasWatched: Bool) {
//        movie.title = title
        movie.hasWatched = !movie.hasWatched
        
        putToServer(movie: movie)
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving to core data: \(error)")
        }
    }
    
    func delete(movie: Movie) {
        deleteMovieFromServer(movie: movie)
        
        let moc = CoreDataStack.shared.mainContext
        moc.delete(movie)
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving to core data: \(error)")
        }
    }
    
    // MARK: DataBase
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    typealias CompletionHandler = (Error?) -> Void
    
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
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                DispatchQueue.main.async {
                    completion(NSError())
                }
                return
            }
            
            do {
                let movieRepresentations = try JSONDecoder().decode(MovieRepresentations.self, from: data).results
                DispatchQueue.main.async {
                    self.searchedMovies = movieRepresentations
                    completion(nil)
                }
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }.resume()
    }
    
    func fetchSingleMovieFromPersistentStore(withUUID uuid: UUID, context: NSManagedObjectContext) -> Movie? {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching movie with uuid \(uuid): \(error)")
            return nil
        }
    }
    
    func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched ?? false
    }
    
    private let firebaseBaseURL = URL(string: "https://moviesprint4.firebaseio.com/")!
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = firebaseBaseURL.appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movie from server: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            guard let data = data else {
                NSLog("No data returned by data movie")
                DispatchQueue.main.async {
                    completion(NSError())
                }
                return
            }
            
            do {
                var movieRepresentations: [MovieRepresentation] = []
                let decodedMovies = try JSONDecoder().decode([String : MovieRepresentation].self, from: data)
                movieRepresentations = decodedMovies.map { $0.value }
                
                // Create backgroundContext for CoreData work
                let backgroundMOC = CoreDataStack.shared.container.newBackgroundContext()
                
                try self.updateMovies(with: movieRepresentations, context: backgroundMOC)
                
            } catch {
                NSLog("Error decoding movie representations: \(error)")
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
    
    func updateMovies(with representations: [MovieRepresentation], context: NSManagedObjectContext) throws {
        var error: Error?
        
        context.performAndWait {
            for movieRep in representations {
    
                guard let uuid = movieRep.identifier else { return }
                
                let movie = self.fetchSingleMovieFromPersistentStore(withUUID: uuid, context: context)
                
                if let movie = movie {
                    if movie != movieRep {
                        self.update(movie: movie, with: movieRep)
                    }
                } else {
                    Movie(movieRepresentation: movieRep, context: context)
                }
            }
            
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        
        if let error = error {
            throw error
        }
    }
    
    func putToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else { return }
        
        let requestURL = firebaseBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movie)
        } catch {
            NSLog("Error encoding movie \(movie): \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTing movie to server: \(error)")
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
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        guard let uuid = movie.identifier else { return }
        
        let requestURL = firebaseBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error DELETing movie from server: \(error)")
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
