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
    
    func update(movie: Movie, hasWatched: Bool) {
        movie.hasWatched = hasWatched
        saveToPersistentStore()
        let movieRep = MovieRepresentation(title: movie.title!, identifier: movie.identifier, hasWatched: movie.hasWatched)
        put(movieRepresentation: movieRep)
    }
    
    func put(movieRepresentation: MovieRepresentation, completion: @escaping (Error?) -> Void = {_ in }) {
        
        let id = movieRepresentation.identifier?.uuidString ?? UUID().uuidString
        
        let url = URL(string: "https://nates-movies.firebaseio.com/")!
        let jsonURL = url.appendingPathComponent(id).appendingPathExtension("json")
        
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
