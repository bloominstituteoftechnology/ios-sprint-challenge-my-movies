//
//  MovieController+APIHelper.swift
//  MyMovies
//
//  Created by Jake Connerly on 8/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension MovieController {
    
    // MARK: - CRUD Methods
    
    // Create
    func createMovie(with title: String, hasWatched: Bool, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            let movie = Movie(title: title, hasWatched: hasWatched)
            do{
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving context when creating new task :\(error)")
            }
            put(movie: movie)
        }
    }
    
    // Update
    func updateMovie(movie: Movie, with title: String, hasWatched: Bool, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            movie.title = title
            movie.hasWatched = hasWatched
            
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving context when updating entry:\(error)")
            }
            put(movie: movie)
        }
    }
    
    // Update Movie with Entry Representation Method
    func update(movie: Movie, with movieRepresentation: MovieRepresentation) {
        guard let hasWatched = movieRepresentation.hasWatched else { return }
        movie.title      = movieRepresentation.title
        movie.identifier = movieRepresentation.identifier
        movie.hasWatched = hasWatched
    }
    
    // Delete
    func deleteMovie(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        deleteMovieFromServer(movie: movie)
        context.performAndWait {
            context.delete(movie)
            
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving context when deleting entry:\(error)")
            }
        }
    }
    
    // Fetch SINGLE Movie From Persistant Store
    func fetchSingleMovieFromPersistentStore(identifier: String, context: NSManagedObjectContext) -> Movie? {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        var movie: Movie? = nil
        context.performAndWait {
            do {
                movie = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching entry with identifier \(identifier):\(error)")
                movie = nil
            }
        }
        return movie
    }
    
    // Update Persistant Store
    func updatePersistentStore(forMovieIn movieRepresentations: [MovieRepresentation], for context: NSManagedObjectContext) {
        
        context.performAndWait {
            for movieRep in movieRepresentations {
                guard let identifier = movieRep.identifier else { continue }
                
                if let movie = self.fetchSingleMovieFromPersistentStore(identifier: identifier, context: context) {
                    guard let hasWatched = movieRep.hasWatched else { return }
                    movie.title      = movieRep.title
                    movie.identifier = movieRep.identifier
                    movie.hasWatched = hasWatched
                } else {
                    Movie(movieRepresentation: movieRep, context: context)
                }
            }
            
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving context: \(error)")
                context.reset()
            }
        }
    }
}
