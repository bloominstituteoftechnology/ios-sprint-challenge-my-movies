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
    
    // MARK: - Movie Database API
    
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
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    
    // MARK: - Firebase
    
    let firebaseURL = URL(string: "https://my-movies-1ff6c.firebaseio.com/")!
    
    
    func addMovie(title: String, identifier: UUID? = UUID()) {
        let movie = Movie(title: title, identifier: identifier, hasWatched: false)
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving context: \(error)")
        }
        put(movie: movie)
    }
    
    func updateMovie(movie: Movie, title: String, identifier: UUID, hasWatched: Bool) {
        
        movie.title = title
        movie.identifier = identifier
        movie.hasWatched.toggle()
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving context: \(error)")
        }
        put(movie: movie)
    }
    
    func removeMovie(movie: Movie) {
        let moc = CoreDataStack.shared.mainContext
        moc.delete(movie)
        deleteMovieFromServer(movie)
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving context: \(error)")
        }
        
    }
    
    func put(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        
        let uuid = movie.identifier?.uuidString ?? UUID().uuidString
        let requestURL = firebaseURL.appendingPathComponent(uuid).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            var representation = movie.movieRepresentation
            
            representation.identifier = UUID(uuidString: uuid)
            movie.identifier = UUID(uuidString: uuid)
            do {
                try CoreDataStack.shared.save()
            } catch {
                NSLog("Error saving context: \(error)")
            }
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding task \(movie): \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error putting task to server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            }.resume()
    }
    
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching tasks: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(error)
                return }
            
            do {
                let movieReps = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                let backGroundContext = CoreDataStack.shared.container.newBackgroundContext()
                
                try self.updateMovies(with: movieReps, context: backGroundContext)
                completion(nil)
                
            } catch {
                NSLog("Error decoding task representations: \(error)")
                completion(nil)
                return
            }
            }.resume()
    }
    
    private func updateMovies(with representations: [MovieRepresentation], context: NSManagedObjectContext) throws {
        
        var error: Error? = nil
        
        context.performAndWait {
            for movieRep in representations {
                guard let uuid = UUID(uuidString: movieRep.identifier!.uuidString) else {continue}
                
                let movie = self.movie(for: uuid, context: context)
                
                if let movie = movie {
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
    
    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.identifier = representation.identifier
        movie.hasWatched = representation.hasWatched ?? movie.hasWatched
    }
    
    func fetchSingleMovieFromStore(UUID uuid: String) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid)
        
        do {
            let moc = CoreDataStack.shared.mainContext
            return try moc.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching entry with uuid \(uuid): \(error)")
            return nil
        }
    }
    
    
    private func movie(for uuid: UUID, context: NSManagedObjectContext) -> Movie? {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        
        fetchRequest.predicate = predicate
        
        var result: Movie? = nil
        context.performAndWait {
            
            
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching task with UUID: \(uuid): \(error)")
                
            }
        }
        return result
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            print(response!)
            completion(error)
            }.resume()
    }
    
    
}
