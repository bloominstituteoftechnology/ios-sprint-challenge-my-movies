//
//  MyMovieController.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_34 on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import CoreData

class MyMovieController {
    
    init() {
       // fetchMoviesFromServer()
    }
    
    let baseURL = URL(string: "https://awesome-c0782.firebaseio.com/")!
    
    func movie(for uuid: UUID, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        
        var movie: Movie?
        
        context.performAndWait {
            do {
                movie = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching movie with \(uuid): \(error)")
            }
        }
        return movie
    }
    
    func update(_ movie: Movie, title: String, hasWatched: Bool?) {
        guard let hasWatched = hasWatched else { return }
        
        movie.title = title
        movie.hasWatched = hasWatched
        
    }
    
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        
        let url = baseURL.appendingPathExtension("json")
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let movieRepresentations = try jsonDecoder.decode([String: MovieRepresentation].self, from: data)
              
                let backgroundMoc = CoreDataStack.shared.container.newBackgroundContext()
                
                backgroundMoc.performAndWait {
                    
                    for (_, movieRep) in movieRepresentations {
                        
                        if let movie = self.movie(for: movieRep.identifier!, context: backgroundMoc) {
                            self.update(movie, title: movieRep.title, hasWatched: movieRep.hasWatched)

                        } else {
                            Movie(movieRepresentation: movieRep, context: backgroundMoc)
                        }
                    }
                    
                    do {
                        try CoreDataStack.shared.save(context: backgroundMoc)
                    } catch {
                        NSLog("Error saving background context: \(error)")
                    }
                }
                
                completion(nil)
                
            } catch {
                NSLog("error decoding MovieRepresentations: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    func put(_ movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        let identifier = movie.identifier ?? UUID()
        
        let url = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        guard let movieRepresentation = movie.movieRepresentation else {
            NSLog("Unable to convert movie to movierepresentation")
            completion(NSError())
            return
        }
        
        let encoder = JSONEncoder()
        
        do {
            let movieJSON = try encoder.encode(movieRepresentation)
            
            request.httpBody = movieJSON
        } catch {
            NSLog("unable to encode movie representation: \(error)")
            completion(error)
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error putting movie to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping (Error?) -> Void = { _ in}) {
        guard let identifier = movie.identifier else {
            completion(NSError())
            return
        }
        
        let url = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                NSLog("Error deleting movie: \(error)")
                completion(error)
            }
            completion(nil)
        }.resume()
    }
}
