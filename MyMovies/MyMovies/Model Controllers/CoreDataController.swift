//
//  CoreDataController.swift
//  MyMovies
//
//  Created by Lotanna Igwe-Odunze on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController {
    
    static var shared = CoreDataController()
    
    //Fetch Results
    lazy var fetchResults: NSFetchedResultsController<Movie> = {
        let context = CoreDataStack.shared.mainContext
        var request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true), NSSortDescriptor(key:"title", ascending:true)]
        
        var fetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "hasWatched",
            cacheName: nil)
        
        do {
            try fetchController.performFetch()
        } catch {
            NSLog("Error fetching data from local store: \(error)")
        }
        
        return fetchController
    }()
    
    //Create a new movie if there isn't one.
    func newMovie(title: String, doPut: Bool = true, doSave: Bool = true, moc: NSManagedObjectContext = CoreDataStack.shared.mainContext)
    {
        moc.perform {
            let movie = Movie(title: title)
            if doPut {
                FirebaseController().sendMovie(movie: movie)
            }
            if doSave {
                do {
                    try moc.save()
                } catch {
                    NSLog("Failed to save while creating a new movie")
                }
            }
        }
    }
    
    //Fetch the existing movie if there's already one with the same title.
    func movieExistsLocally(title:String, moc: NSManagedObjectContext = CoreDataStack.shared.mainContext) -> Bool
    {
        var result = false
        moc.performAndWait {
            let req: NSFetchRequest<Movie> = Movie.fetchRequest()
            req.predicate = NSPredicate(format: "title = %@", title)
            var movie: Movie?
            do {
                movie = try moc.fetch(req).first
            } catch {
                showErrors(Empties, "Error searching")
            }
            result = movie != nil
        }
        return result
    }
    
    //Match data to Movie Representation
    func referToMovieRep(movieRep: MovieRepresentation, moc: NSManagedObjectContext) throws
    {
        var caughtError:Error?
        moc.perform {
            let req: NSFetchRequest<Movie> = Movie.fetchRequest()
            req.predicate = NSPredicate(format: "identifier = %@", movieRep.identifier! as NSUUID)
            var movie: Movie?
            do {
                movie = try moc.fetch(req).first
            } catch {
                caughtError = error
            }
            
            if let movie = movie {
                movie.assignMovie(tempMovie: movieRep)
            } else { _ = Movie(title: movieRep.title, identifier: movieRep.identifier, hasWatched: movieRep.hasWatched ?? false, context: moc)
            }
        }
        
        if let caughtError = caughtError {
            throw caughtError
        }
    }
    
    //Flip between watched and unwatched movies.
    func watchToggle(_ movie:Movie, send:Bool = true, saved:Bool = true)
    {
        movie.managedObjectContext!.performAndWait {
            movie.hasWatched = !movie.hasWatched
            if send {
                FirebaseController().sendMovie(movie: movie)
            }
            if saved {
                do {
                    try movie.managedObjectContext?.save()
                } catch {
                    NSLog("Couldn't save movie status")
                }
            }
        }
    }
    
    //Delete Movie
    func deleteMovie( movie: Movie, index: IndexPath, _ completion:@escaping Completions = Empties)
    {
        let stub = movie.getMovie() //Get a reference of the movie on Firebase
        
        guard let moc = movie.managedObjectContext else { return }
        
        moc.performAndWait {
            moc.delete(movie) //Delete the movie
            
            do {
                try moc.save() //Save the change
                
            } catch {
                
                self.showErrors(completion, "Unable to save moc")
                return
            }
        }
        
        let req = FirebaseController().buildURLRequest([stub.identifier!.uuidString], "DELETE")
        
        URLSession.shared.dataTask(with: req) { (_, _, error) in
            if let error = error {
                self.showErrors(completion, "Error deleting: \(error)")
                return
            }
            
            completion(nil)
            
            }.resume()
    }
    
    //Report Errors
    func showErrors(_ completion: @escaping Completions, _ error: String)
    {
        NSLog(error)
        completion(error)
    }
}
