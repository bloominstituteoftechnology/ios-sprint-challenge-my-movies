//
//  MoviesManager.swift
//  MyMovies
//
//  Created by Lotanna Igwe-Odunze on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

typealias CompletionHandler = (String?) -> Void
let EmptyHandler:CompletionHandler = {_ in}


class MoviesManager {
    
    static var shared = MoviesManager()
    
    //Firebase
    private let firebaseURL = URL(string: "https://sprint-4-challenge.firebaseio.com/")!
    
    
    //Fetch Results
    lazy var fetchResults:NSFetchedResultsController<Movie> = {
        let context = CoreDataStack.shared.mainContext
        var request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true),
                               NSSortDescriptor(key:"title", ascending:true)]
        
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
                self.sendMovie(movie: movie)
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
    func existingMovie(title:String, moc: NSManagedObjectContext = CoreDataStack.shared.mainContext) -> Bool
    {
        var result = false
        moc.performAndWait {
            let req: NSFetchRequest<Movie> = Movie.fetchRequest()
            req.predicate = NSPredicate(format: "title = %@", title)
            var movie: Movie?
            do {
                movie = try moc.fetch(req).first
            } catch {
                logError(EmptyHandler, "Error searching")
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
                movie.assignMovie(movieRep: movieRep)
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
                self.sendMovie(movie: movie)
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
    func deleteMovie(movie:Movie, _ completion:@escaping CompletionHandler = EmptyHandler)
    {
        let stub = movie.grabMovie()
        guard let moc = movie.managedObjectContext else { return }
        moc.performAndWait {
            moc.delete(movie)
            do {
                try moc.save()
            } catch {
                self.logError(completion, "Unable to save moc")
                return
            }
        }
        
        let req = buildRequest([stub.identifier!.uuidString], "DELETE")
        URLSession.shared.dataTask(with: req) { (_, _, error) in
            if let error = error {
                self.logError(completion, "Error deleting: \(error)")
                return
            }
            
            completion(nil)
            
            }.resume()
    }
    
    //Put new movie on FB
    func sendMovie(movie:Movie, _ completion:@escaping CompletionHandler = EmptyHandler)
    {
        var data:Data?
        do {
            data = try JSONEncoder().encode(movie.grabMovie())
        } catch {
            logError(completion, "Couldn't encode movie: \(error)")
        }
        
        let req = buildRequest([movie.identifier!.uuidString], "PUT", data)
        URLSession.shared.dataTask(with: req) { (_, _, error) in
            if let error = error {
                self.logError(completion, "Error putting: \(error)")
                return
            }
            completion(nil)
            }.resume()
    }
    
    //Retrieve movie from FB
    func getMovieOnFB(_ completion:@escaping CompletionHandler = EmptyHandler)
    {
        let moc = CoreDataStack.shared.container.newBackgroundContext()
        let req = buildRequest([], "GET")
        URLSession.shared.dataTask(with: req) { data, _, error in
            if let error = error {
                self.logError(completion, "Error fetching: \(error)")
            }
            
            guard let data = data else { self.logError(completion, "Couldn't fetch data."); return}
            
            do {
                let stubs = try JSONDecoder().decode([String: MovieRepresentation].self, from:data)
                for (_, stub) in stubs {
                    try self.referToMovieRep(movieRep: stub, moc: moc)
                }
                try CoreDataStack.save(moc:moc)
                completion(nil)
            } catch {
                self.logError(completion, "Couldn't decode data: \(error)")
            }
            }.resume()
    }
    
    
    func buildRequest(_ ids:[String], _ httpMethod:String, _ data:Data?=nil) -> URLRequest
    {
        var url = firebaseURL
        url.appendPathComponent("movies")
        for id in ids {
            url.appendPathComponent(id)
        }
        url.appendPathExtension("json")
        var req = URLRequest(url: url)
        req.httpMethod = httpMethod
        req.httpBody = data
        return req
    }
    //Remove this and see if it still works
    func logError(_ completion:@escaping CompletionHandler, _ error:String)
    {
        NSLog(error)
        completion(error)
    }
    
}

