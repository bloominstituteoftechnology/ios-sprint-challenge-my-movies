//
//  FirebaseController.swift
//  MyMovies
//
//  Created by Jeremy Taylor on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import CoreData

let baseURL = URL(string: "https://mymovies-6a686.firebaseio.com/")!

class FirebaseController {
    
    typealias CompletionHandler = (Error?) -> Void
    
    init() {
        fetchMoviesFromServer()
    }
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching saved movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned by data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                let backgroundMoc = CoreDataStack.shared.container.newBackgroundContext()
                
                try self.updateMovies(with: movieRepresentations, context: backgroundMoc)
                completion(nil)
            } catch {
                NSLog("Error decoding movie representations: \(error)")
                completion(error)
                return
            }
            }.resume()
    }
    
    private func updateMovies(with representations: [MovieRepresentation], context: NSManagedObjectContext) throws {
        
        var error: Error?
        
        context.performAndWait {
            for movieRep in representations {
                guard let uuid = movieRep.identifier else { continue }
                
                let movie = self.movie(forUUID: uuid, context: context)
                
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
    
    func put(movie: Movie, completion: @escaping CompletionHandler = {_ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard let representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding movie: \(movie): \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting movie to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    private func update(movie: Movie, with representation: MovieRepresentation) {
        
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched!
        
    }
    
    func delete(movie: Movie) {
        let moc = CoreDataStack.shared.mainContext
        moc.performAndWait {
            moc.delete(movie)
            deleteMovieFromServer(movie: movie)
            do {
                try moc.save()
            } catch {
                NSLog("Error saving to Core Data: \(error)")
            }
        }
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = baseURL.appendingPathComponent("\(uuid)").appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error Deleting data on server: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    private func movie(forUUID uuid: UUID, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching movie with uuid: \(uuid): \(error)")
            return nil
        }
    }
}
