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
        
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid)
        
        var movie: Movie?
        
        context.performAndWait {
            do {
                task = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching movie with \(uuid): \(error)")
            }
        }
        return movie
    }
    
    func update(_ movie: Movie, title: String, hasWatched: Bool?) {
        movie.title = title
        movie.hasWatched = hasWatched ?? false
        
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
                        
                        if let movie = self.movie(for: movieRep.identifier, context: backgroundMoc) {
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
}
