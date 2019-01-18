//
//  MyMoviesController.swift
//  MyMovies
//
//  Created by Benjamin Hakes on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MyMoviesController{

    typealias CompletionHandler = (Error?) -> Void
    
    private let baseURL = URL(string: "https://tasks-f46aa.firebaseio.com/")!

    init() {
        // TODO: Implement init
//        fetchEntriesFromServer()
        
    }
    
    
    func fetchEntriesFromServer(completionHandler: @escaping CompletionHandler = {_ in }){
        
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching entries: \(error)")
                completionHandler(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned by data movie")
                completionHandler(NSError())
                return
            }
            
            let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
            
            do {
                let movieRepresentationsDict = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
                let movieRepresentations = Array(movieRepresentationsDict.values)
                
                for movieRep in movieRepresentations {
                    
                    
                    // TODO: Make sure that this is not duplicating
                    guard let uuid = movieRep.identifier else { fatalError("Value of movie should have an identifier and did not")
                    }
    
                    // TODO: Make sure that this is the correct context/queue
                
                    if let movie = self.movie(forUUID: uuid, in: backgroundContext){
                        // we already have a local task for this
                        self.update(movie: movie, with: movieRep)
                        
                    } else {
                        // need to create a new task in Core Data
                        backgroundContext.perform {
                            let _ = Movie(movieRepresentation: movieRep, context: backgroundContext)
                        }
                    }
                    
                }
                
                try CoreDataStack.shared.save(context: backgroundContext)
                
            } catch {
                NSLog("Error decoding tasks: \(error)")
                completionHandler(error)
                return
            }
            
            completionHandler(nil)
            }.resume()
        
    }
    
    func put(movie: Movie, completionHandler: @escaping CompletionHandler = { _ in }) {
        
        // turn the movie into an movie representation
        
        // send the movie representation to the server
        
        guard let uuid = movie.identifier else {fatalError("could not get UUID")}
        
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            
            request.httpBody = try JSONEncoder().encode(movie)
            
            URLSession.shared.dataTask(with: request){ (_, _, error) in
                if let error = error {
                    print ("Error putting task to server: \(error)")
                }
                completionHandler(error)
                }.resume()
            
            
        } catch {
            print("errors putting movie to server \(error)")
            completionHandler(error)
        }
        
    }
    
    func saveToPersistentStore(){
        let moc = CoreDataStack.shared.mainContext
        do {
            try moc.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
        
    }
    
    func createMovie(title: String){
        
        let movie = Movie(title: title)
        put(movie: movie)
        saveToPersistentStore()
    }
    
    private func update(movie: Movie, with representation: MovieRepresentation){
        guard let moc = movie.managedObjectContext else { return }
        guard let hasWatched = representation.hasWatched else {
            fatalError("Movie title did not contain a hasWatched value and should have")
        }
        moc.performAndWait {
            movie.hasWatched = hasWatched
            movie.title = representation.title
            movie.identifier = representation.identifier
        }
    }
    
    /**
     'movie' is a private function with the purpose of looking up a movie by UUID in the persistent store and returning the movie related to that UUID if it exists.
     - Parameter uuid: The UUID that is being looked up.
     - Parameter managedObjectContext: a given NSManagedObjectContext.
     
     - Returns: the movie for the given UUID and the given NSManagedObjectContext.
     */
    private func movie(forUUID uuid: UUID, in managedObjectContext: NSManagedObjectContext) -> Movie? {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        
        var movie: Movie?
        
        managedObjectContext.performAndWait {
            movie = (try? managedObjectContext.fetch(fetchRequest))?.first
        }
        
        return movie
    }

    
    
}
