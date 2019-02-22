//
//  UpdateController.swift
//  MyMovies
//
//  Created by Nathanael Youngren on 2/22/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import CoreData

class UpdateController {
    
    let moc = CoreDataStack.shared.mainContext
    
    let firebaseURL = URL(string: "https://nates-movies.firebaseio.com/")!
    
    init() {
        syncMoviesFromServer()
    }
    
    func update(movie: Movie, hasWatched: Bool) {
        movie.hasWatched = hasWatched
        saveToPersistentStore()
        let movieRep = MovieRepresentation(title: movie.title!, identifier: movie.identifier, hasWatched: movie.hasWatched)
        put(movieRepresentation: movieRep)
    }
    
    func updateCoreData(movieRep: MovieRepresentation, movie: Movie) {
        movie.title = movieRep.title
        movie.identifier = movieRep.identifier
        movie.hasWatched = movieRep.hasWatched ?? false
        saveToPersistentStore()
        syncMoviesFromServer()
    }
    
    func delete(movie: Movie) {
        let movieRep = MovieRepresentation(title: movie.title!, identifier: movie.identifier, hasWatched: movie.hasWatched)
        moc.delete(movie)
        saveToPersistentStore()
        deleteFromServer(movieRepresentation: movieRep)
    }
    
    func put(movieRepresentation: MovieRepresentation, completion: @escaping (Error?) -> Void = {_ in }) {
        
        let id = movieRepresentation.identifier?.uuidString ?? UUID().uuidString

        let jsonURL = firebaseURL.appendingPathComponent(id).appendingPathExtension("json")
        
        var request = URLRequest(url: jsonURL)
        request.httpMethod = "PUT"
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(movieRepresentation)
        } catch {
            NSLog("Error encoding data: \(NSError())")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error connecting to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    func deleteFromServer(movieRepresentation: MovieRepresentation, completion: @escaping (Error?) -> Void = {_ in }) {
       
        let id = movieRepresentation.identifier?.uuidString ?? UUID().uuidString
        
        let jsonURL = firebaseURL.appendingPathComponent(id).appendingPathExtension("json")
        
        var request = URLRequest(url: jsonURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting from server")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func fetchSingleMovieFromPersistenceStore(movieID: String, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", movieID)
        
        var movie: Movie?
        moc.performAndWait {
            do {
                movie = try moc.fetch(fetchRequest).first
            } catch {
                movie = nil
            }
        }
        return movie
    }
    
    func syncMoviesFromServer(completion: @escaping (Error?) -> Void = {_ in }) {
        
        let jsonURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: jsonURL) { (data, _, error) in
            if let error = error {
                NSLog("Error syncing with server")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("Error fetching data from server")
                completion(NSError())
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode([String: MovieRepresentation].self, from: data)
                let movieReps = decodedData.map({ $0.value })
                let backgroundMOC = CoreDataStack.shared.container.newBackgroundContext()
                self.iterate(movieRepresentations: movieReps, context: backgroundMOC)
                completion(nil)
            } catch {
                NSLog("Error decoding data")
                completion(NSError())
            }
        }.resume()
    }
    
    func iterate(movieRepresentations: [MovieRepresentation], context: NSManagedObjectContext) {
        for movieRep in movieRepresentations {
            moc.performAndWait {
                let movie = self.fetchSingleMovieFromPersistenceStore(movieID: movieRep.identifier?.uuidString ?? UUID().uuidString, context: context)
                
                if movie == nil {
                    Movie(movieRepresentation: movieRep)
                } else {
                    if movieRep == movie! {
                        return
                    } else {
                        self.updateCoreData(movieRep: movieRep, movie: movie!)
                    }
                }
                saveToPersistentStore()
            }
        }
    }
    
    func saveToPersistentStore() {
        moc.performAndWait {
            do {
                try moc.save()
            } catch {
                moc.reset()
                NSLog("Error saving to persistent store")
            }
        }
    }
}
