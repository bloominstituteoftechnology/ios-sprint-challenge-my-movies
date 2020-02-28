//
//  MovieDataController.swift
//  MyMovies
//
//  Created by Elizabeth Wingate on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MovieDataController {
      
    typealias  CompletionHandler = (Error?) -> Void
    let baseURL = URL(string: "https://coredatasprintchallenge-8e04a.firebaseio.com/")!
    static let shared = MovieDataController()
    
    init() {
           fetchMoviesFromServer()
       }
    
    // MARK: - Core Data Functions (CRUD)
    
    //Create
    func createMovie(title: String, hasWatched: Bool) {
        let newMovie = Movie(context: CoreDataStack.shared.mainContext)
        
        newMovie.title = title
        newMovie.hasWatched = hasWatched

        saveToPersistentStore()
        put(movie: newMovie)
    }
    
    //Saves CoreData
    func saveToPersistentStore() {
       let moc = CoreDataStack.shared.mainContext

        do {
            try moc.save()
       } catch {
            fatalError("Error saving to core data: \(error)")
        }
  }

    //Update
    func updateMovie(movie: Movie, hasWatched: Bool) {
        movie.hasWatched = hasWatched
        
        saveToPersistentStore()
        put(movie: movie)
    }
    
    //Delete
    func deleteMovie(movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        deleteMovieFromServer(movie: movie)
        saveToPersistentStore()
    }
    
    // MARK: - Firebase Functions
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {

        do {

        guard let representation = movie.movieRepresentation else { throw NSError() }
        let uuid = representation.identifier?.uuidString
        let requestURL = baseURL.appendingPathComponent(uuid!).appendingPathExtension("json")

        var request = URLRequest(url: requestURL)
               request.httpMethod = "PUT"

        let body = try JSONEncoder().encode(representation)
               request.httpBody = body
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error saving movie: \(error)")
        }
            completion(error)
        }.resume()
            
        } catch {
         NSLog("Error encoding movie: \(error)")
            completion(error)
            return
    }
}
    func update(movie: Movie, with representation: MovieRepresentation) {
    guard let context = movie.managedObjectContext else { return }
        
        context.perform {
        guard movie.identifier == representation.identifier else {
            fatalError("Updating the wrong movie!")
        }
          movie.hasWatched = representation.hasWatched ?? false
    }
}
    // Fetch from Core Data - Perform on background
       func fetchSingleMovieFromPersistentStore(identifier: String, context: NSManagedObjectContext) -> Movie? {
           
           let request: NSFetchRequest<Movie> = Movie.fetchRequest()
           let predicate = NSPredicate(format: "identifier == %@", identifier)
           request.predicate = predicate
           
           var movie: Movie?
           context.performAndWait {
               
               movie = (try? context.fetch(request))?.first
           }
           
           return movie
       }
       
       // Fetch from Core Data
       func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
           
           let requestURL = baseURL.appendingPathExtension("json")
           

    URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
            NSLog("Error fetching entries: \(error)")
            completion(error)
            return
        }
               
        guard let data = data else {
            NSLog("No data returned from the data task")
            completion(NSError())
            return
        }
        let moc = CoreDataStack.shared.container.newBackgroundContext()
               
        var dataArray: [MovieRepresentation] = []
               
        do {
         dataArray = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({$0.value})
                       
        for eachMovie in dataArray {
        if let movie = self.fetchSingleMovieFromPersistentStore(identifier: (eachMovie.identifier?.uuidString)!, context: moc) {
        self.update(movie: movie, with: eachMovie)
        } else {
             
            moc.perform {
            _ = Movie(movieRepresentation: eachMovie, context: moc)
        }
    }
}
        try CoreDataStack.shared.saveTo(context: moc)
            completion(nil)
        } catch {
            NSLog("Error decoding or importing tasks: \(error)")
            completion(error)
        }
    }.resume()
}
    
//    func loadFromPersistentStore() -> [Movie] {
//
//        var movie: [Movie] {
//            do {
//                let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
//                let result = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
//                return result
//            } catch {
//                fatalError("Can't fetch Data \(error)")
//            }
//
//        }
//        return movie
//    }

    // Delete from server
       func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        do {
            guard let representation = movie.movieRepresentation else { throw NSError() }
                   
            let uuid = representation.identifier?.uuidString
                   
                   // Append identifier of the entry parameter to the baseURL
            let requestURL = baseURL.appendingPathComponent(uuid!).appendingPathExtension("json")
                   
            var request = URLRequest(url: requestURL)
            request.httpMethod = "DELETE"
                
            URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                    NSLog("Error deleting movie: \(error)")
            }
                completion(error)
            }.resume()
                   
        } catch {
            NSLog("Error encoding task: \(error)")
            completion(error)
            return
    }
  }
}
