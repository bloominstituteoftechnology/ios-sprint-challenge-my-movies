//
//  MyMovieController.swift
//  MyMovies
//
//  Created by Ryan Murphy on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData



class MyMovieController {
    
    static let shared = MyMovieController()
    
    typealias  CompletionHandler = (Error?) -> Void
    
    let baseURL = URL(string: "https://journal-48ed0.firebaseio.com/")!
    
    init() {
        fetchMoviesFromServer()
    }
    
    func createMovie(title: String, hasWatched: Bool) {

        let newMovie = Movie(context: CoreDataStack.shared.mainContext)
        newMovie.title = title
        newMovie.hasWatched = hasWatched
        saveToPersistentStore()
        put(movie: newMovie)
        
    }

    func saveToPersistentStore() {
        let moc = CoreDataStack.shared.mainContext
        
        do {
            try moc.save()
        } catch {
            fatalError("Error saving to core data: \(error)")
        }
    }


    func updateMovie(movie: Movie, hasWatched: Bool) {
  
        movie.hasWatched = hasWatched
        saveToPersistentStore()
        put(movie: movie)
        
    }
    
    func deleteMovie(movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        deleteMovieFromServer(movie: movie)
        saveToPersistentStore()
        
        
    }

    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        do {
            
            guard let representation = movie.movieRepresentation else { throw NSError() }
            
            let uuid = representation.identifier?.uuidString
            let requestURL = baseURL.appendingPathComponent(uuid!).appendingPathExtension("json")
            
            var request = URLRequest(url: requestURL)
            request.httpMethod = "PUT"
            let body = try JSONEncoder().encode(representation)
            request.httpBody = body
            
            URLSession.shared.dataTask(with: request) { (_, _, error) in
                if let error = error {
                    NSLog("Error saving movie: \(error)")
                }
                completion(error)
                }.resume()
            
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
            
        }
    }
    
    func update(movie: Movie, with representation: MovieRepresentation) {
 
        guard let context = movie.managedObjectContext else { return }
        context.performAndWait {
            guard movie.identifier == representation.identifier else {
                fatalError("Error updating movie")
            }
            movie.hasWatched = representation.hasWatched ?? false
        }
        
    }
    
    
   
    func fetchSingleMovieFromPersistentStore(uuid: UUID, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        
        var result: Movie? = nil
        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching entry with uuid \(uuid): \(error)")
            }
        }
        return result
    }
    
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned")
                completion(NSError())
                return
            }
            
            
            let backgroundMoc = CoreDataStack.shared.container.newBackgroundContext()
            
            var movieArray: [MovieRepresentation] = []
            
            do {
                movieArray = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({$0.value})

                for singleMovie in movieArray {
                    if let movie = self.fetchSingleMovieFromPersistentStore(uuid: singleMovie.identifier!, context: backgroundMoc) {
                        self.update(movie: movie, with: singleMovie)
                    } else {
                        backgroundMoc.performAndWait {
                            _ = Movie(movieRepresentation: singleMovie, context: backgroundMoc)
                        }
                    }
                }
                
                try CoreDataStack.shared.save(context: backgroundMoc)
                completion(nil)
                
            } catch {
                NSLog("Error decoding or importing tasks: \(error)")
                completion(error)
            }
            
            }.resume()
    }
    
    
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        guard let identifier = movie.identifier else {
            NSLog("movie identifier is nil")
            completion(NSError())
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error deleting movie from server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            }.resume()
    }
}
