//
//  MyMoviesController.swift
//  MyMovies
//
//  Created by Sameera Roussi on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

let baseURL = URL(string: "https://mymovies-20257.firebaseio.com/")!

class MyMoviesController {
    
    init() {
        fetchMoviesFromServer()
    }
    
    
    // MARK: - Fetch from Sercer
    func fetchMoviesFromServer(completion: @escaping ((Error?) -> Void)  = {_ in }) {
        
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            // Check for errors from URLSession
            if let error = error {
                NSLog("Error fetching entries from server: \(error)")
                completion(error)
                return
            }
            
            // No errors. Check for data
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            // Got some data let's decode it and translate it to the moc.  This will be done in the background
            let moc = CoreDataStack.shared.container.newBackgroundContext()
            do {
                let movieReps = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({$0.value})
                self.updateMovies(with: movieReps, in: moc)
            } catch {
                NSLog("Error decoding JSON data \(error)")
                completion(error)
                return
            }
            
            // Save the  fetched movies to persistent storage
            moc.perform {
                do {
                    try moc.save()
                    completion(nil)
                } catch {
                    NSLog("Error saving context: \(error)")
                    completion(error)
                }
            }
            
        } .resume()
    }
    
    // MARK: - PUT
    func put(movie: Movie, completion: @escaping ((Error?) -> Void) = {_ in }) {

        let identifier = movie.identifier?.uuidString ?? UUID().uuidString
        let requestURL = baseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            
            // Make the encodable tweenie
            guard let movieRep = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            request.httpBody = try JSONEncoder().encode(movieRep)
        } catch {
            print("Error attempting to PUT movie: \(error)")
            completion(error)
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting movie \(identifier): \(error)")
                completion(error)
                return
            }
            completion(nil)
        } .resume()
    }  // end put
    
    
    // MARK: - Private functions
    private func updateMovies(with representations: [MovieRepresentation], in context: NSManagedObjectContext) {
        context.performAndWait {
            for movieRep in representations {
                // A new movie has been added so go create the movie
                guard let identifier = movieRep.identifier?.uuidString else { continue }
                
                // Let's go look for the movie - one at a time.  Will use a background context
                if let movie = fetchSingleEntryFromPersistentStore(with: identifier, in: context) {
                    movie.title = movieRep.title
                    movie.hasWatched = movieRep.hasWatched ?? false
                    movie.identifier = movieRep.identifier
                } else {
                    _ = Movie(movieRepresentation: movieRep, context: context)
                }
            }
        }
    }
    
    private func fetchSingleEntryFromPersistentStore(with identifier: String, in context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        
        var result: Movie? = nil
        do {
            result = try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching single entry for \(identifier): \(error)")
        }
        return result
    }
    
    
    // MARK: - Persistent save and CRUD functions
    
    // Save
    func saveMovie(context: NSManagedObjectContext) {
        context.performAndWait {
            do {
                try context.save()
            } catch  {
                NSLog("Could not save to persistent store: \(error)")
            }
        }
    }

    
    // Crud
    func createMovie(title: String) {
        let movie = Movie(title: title)
        put(movie: movie)
    }


    // crUd
    
    // cruD

    
} // end class
