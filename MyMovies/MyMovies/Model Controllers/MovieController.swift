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
    var movies: [Movie] = []
    private let firebaseURL = URL(string: "https://ios6-lisa.firebaseio.com/")!
    
    // MARK: - Search Properties
    var searchedMovies: [MovieRepresentation] = []
    
    let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    // MARK: - Initializers
    init() {
        fetch()
    }
    
    // MARK: - CRUD
    func create(from movieRep: MovieRepresentation) {
        let moc = CoreDataStack.shared.container.newBackgroundContext()
        
        moc.performAndWait {
            let movie = Movie(movieRepresentation: movieRep, context: moc)
            
            do {
                try CoreDataStack.shared.save(context: moc)
            } catch {
                NSLog("Error saving context: \(error)")
                return
            }
            self.put(movie: movie)
        }
    }
    
    func updateFromRep(movie: Movie, movieRep: MovieRepresentation) {
        guard let hasWatched = movieRep.hasWatched else { return }
        movie.hasWatched = hasWatched
        movie.title = movieRep.title
        movie.identifier = movieRep.identifier
    }
    
    func updateMovies(movieDicts: [MovieRepresentation], context: NSManagedObjectContext) throws {
        context.performAndWait {
            for movieRep in movieDicts {
                guard let identifier = movieRep.identifier else { continue }
                
                if let movie = self.fetchMovieFromStore(identifier: identifier, context: context) {
                    self.updateFromRep(movie: movie, movieRep: movieRep)
                } else {
                    _ = Movie(movieRepresentation: movieRep, context: context)
                }
            }
        }
    }
    
    func delete(movie: Movie) {
        deleteMovieFromServer(movie: movie)
        let moc = CoreDataStack.shared.mainContext
        
        moc.perform {
            do {
                moc.delete(movie)
                try CoreDataStack.shared.save(context: moc)
            } catch {
                NSLog("Error saving context: \(error)")
                return
            }
        }
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        guard let identifier = movie.identifier else { return }
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
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
    
    func toggleHasWatched(for movie: Movie) {
        if movie.hasWatched == false {
            movie.hasWatched = true
        } else {
            movie.hasWatched = false
        }
    }
    
    // MARK: - Networking
    func put(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        guard let identifier = movie.identifier else { completion(NSError()); return }
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movie)
        }
        catch {
            NSLog("Error encoding data: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTing data: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    func fetch(completion: @escaping (Error?) -> Void = { _ in }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching data: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("There is no data.")
                completion(NSError())
                return
            }
            
            do {
                let movieDicts = try Array(JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
                try self.updateMovies(movieDicts: movieDicts, context: backgroundContext)
                try CoreDataStack.shared.save(context: backgroundContext)
                completion(nil)
            }
            catch {
                NSLog("Error decoding data: \(error)")
                completion(error)
                return
            }
            }.resume()
    }
    
    func fetchMovieFromStore(identifier: UUID, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier.uuidString)
        
        do {
            return try context.fetch(fetchRequest).first
        }
        catch {
            NSLog("Error fetching single movie: \(error)")
            return nil
        }
    }
}
