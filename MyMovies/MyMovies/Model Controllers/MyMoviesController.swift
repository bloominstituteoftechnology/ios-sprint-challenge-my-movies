//
//  MyMoviesController.swift
//  MyMovies
//
//  Created by jkaunert on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MyMovieController {
    
    typealias CompletionHandler = (Error?) -> Void
    var movieRepresentations: [MovieRepresentation] = []
    
    private let baseURL = URL(string: "https://ios-sprint-4-mymovies.firebaseio.com/")!
    
    init() {
        fetchMoviesFromServer()
    }
    
    //MARK: - Fetch
    
    //fetch all movies from Firebase
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        var movieRepresentations: [MovieRepresentation] = []
        let moc = CoreDataStack.shared.container.newBackgroundContext()
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("error fetching movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                print("no data returned from the data task")
                completion(NSError())
                return
            }
            
            
            do {
                let decodedResponse = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
                movieRepresentations = Array(decodedResponse.values)
                
            } catch {
                NSLog("Error decoding movie representations: \(error)")
                completion(error)
                return
            }
            
            
            moc.performAndWait {
                self.updatePersistentStore(with: movieRepresentations, context: moc)
            }
            
            do {
                try CoreDataStack.shared.save(context: moc)
            } catch {
                NSLog("Error saving context: \(error).")
                completion(error)
                return
            }
            
            completion(nil)
            return
            
            }.resume()
    }
    
    //update the persisitent store
    private func updatePersistentStore(with movieRepresentations: [MovieRepresentation], context: NSManagedObjectContext) {
//        var importedMovieIdentifiers = Set<String>()
        for movieRepresentation in movieRepresentations {
            if let identifier = movieRepresentation.identifier, let movie = getMovie(identifier: identifier, context: context) {
                if movie != movieRepresentation {
                    update(movie: movie, with: movieRepresentation)
                }
            } else {
                context.perform {
                    self.create(movieRepresentation: movieRepresentation, context: context)
                }
//                create(movieRepresentation: movieRepresentation, context: context)
            }
        }
//             //FIXME: - Refresh Control
//                    let query: NSFetchRequest<NSFetchRequestResult> = Movie.fetchRequest()
//
//             //find all the tasks with identifiers that were NOT updated
//                    query.predicate = NSPredicate(format: "identifier != NULL AND NOT(identifier IN %@)", importedMovieIdentifiers)
//                    let batchDelete = NSBatchDeleteRequest(fetchRequest: query)
//
//                    context.perform {
//                        _ = try? context.execute(batchDelete)
//                    }
    }
    
    
    //MARK: - Global CRUD Methods (Create, Update, Delete)
    
    //CREATE
    public func create(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        let hasWatched = movieRepresentation.hasWatched ?? false
        let identifier = movieRepresentation.identifier ?? UUID()
        
        //create movie from representation
        let movie = Movie(identifier: identifier, title: movieRepresentation.title, hasWatched: hasWatched, managedObjectContext: context)
        
        //save it to moc
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error saving created movie: \(error)")
            return
        }
        
        //save it to Firebase
        putFirebase(movie: movie)
    }
    
    //UPDATE
    public func update(movie: Movie, with representation: MovieRepresentation) {
        guard let context = movie.managedObjectContext else { return }
        
        context.perform {
            guard movie.identifier == representation.identifier else {
                fatalError("unable to update")
            }
            
            movie.title = representation.title
            movie.hasWatched = representation.hasWatched ?? false
            
        }
    }
    
    //DELETE
    public func delete(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        
        //firebase
        deleteFirebase(movie: movie)
        
        //CoreDataStack
        context.delete(movie)
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error saving after deleting movie: \(error)")
        }
        
    }
    
    
    //MARK: - Firebase RESTful Methods
    
    //PUT
    func putFirebase(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        guard let identifier = movie.identifier else {
            NSLog("Movie \(movie) has no identifier")
            completion(NSError())
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movie)
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTting movie to server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            return
            }.resume()
    }
    
    
    //GET
    
    //single entry
    private func getMovie(identifier: UUID, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        let predicate = NSPredicate(format: "identifier = %@", identifier as NSUUID)
        
        fetchRequest.predicate = predicate
        
        var movie: Movie? = nil
        
        context.performAndWait {
            do {
                movie = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching single movie: \(error)")
            }
        }
        return movie
    }
    
    // DELETE
    func deleteFirebase(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        guard let identifier = movie.identifier else {
            NSLog("Movie \(movie) has no identifier")
            completion(NSError())
            return
        }
        
        let uuidString = identifier.uuidString
        
        let requestURL = baseURL.appendingPathComponent(uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("could not delete movie from server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            }.resume()
    }
    
}
