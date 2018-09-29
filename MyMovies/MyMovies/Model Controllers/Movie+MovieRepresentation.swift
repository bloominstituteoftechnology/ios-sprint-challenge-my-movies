//
//  Movie+MovieRepresentation.swift
//  MyMovies
//
//  Created by Ilgar Ilyasov on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension MovieController {
    
    // MARK: - Update Movie from MovieRepresentation
    
    func updateMovie(movie: Movie, movieRepresentation mr: MovieRepresentation) {
        
        guard let id = mr.identifier?.uuidString else {return}
        
        movie.title = mr.title
        movie.identifier = id
        movie.hasWatched = mr.hasWatched ?? false
    }
    
    // MARK: - GET single Movie
    
    func fetchSingleMovieFromPersistentStore(identifier id: String, context: NSManagedObjectContext) -> Movie? {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "identifier == %@", id)
        fetchRequest.predicate = predicate
        
        var movie: Movie?
        
        context.performAndWait {
            do {
                movie = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching a movie: \(error)")
            }
        }
        return movie
    }
    
    
    // MARK: - GET everything
    
    func fetchFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let url = baseURL2.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movie: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned")
                completion(error)
                return
            }
            
            var movieRepresentations = [MovieRepresentation]()
            do {
                movieRepresentations = try JSONDecoder().decode([String:MovieRepresentation].self, from: data).map { $0.value }
            } catch {
                NSLog("Error decoding data: \(error)")
                completion(error)
                return
            }
            
            let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
            
            backgroundContext.performAndWait {
                
                for movieRepresentation in movieRepresentations {
                    
                    guard let id = movieRepresentation.identifier?.uuidString else { return }
                    
                    let movie = self.fetchSingleMovieFromPersistentStore(identifier: id, context: backgroundContext)
                    
                    if let movie = movie, movie != movieRepresentation {
                        self.updateMovie(movie: movie, movieRepresentation: movieRepresentation)
                    } else if movie == nil {
                        _ = Movie(movieRepresentation: movieRepresentation, context: backgroundContext)
                    }
                }
                do {
                    try CoreDataStack.shared.save(context: backgroundContext)
                } catch {
                    NSLog("Error comparing movie to movieRepresentation: \(error)")
                }
            }
            completion(nil)
        }.resume()
    }
}
