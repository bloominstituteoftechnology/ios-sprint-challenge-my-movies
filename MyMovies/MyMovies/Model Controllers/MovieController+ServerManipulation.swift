//
//  MovieController+ServerManipulation.swift
//  MyMovies
//
//  Created by Jake Connerly on 8/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension MovieController {
    
    // PUT Movie in fireBase Data Base
    func put(movie: Movie, completion: @escaping () -> Void = { }) {
        guard let identifier = movie.identifier else { return }
        
        let requestURL = fireBaseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        do {
            let entryData    = try JSONEncoder().encode(movie.movieRepresentation)
            request.httpBody = entryData
        } catch {
            NSLog("Error encoding movie representation:\(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                NSLog("Error PUTing entryRep to server:\(error)")
            }
            completion()
            }.resume()
    }
    
    // DELETE Movie from Firebase
    func deleteMovieFromServer(movie: Movie, completion: @escaping(NetworkError?) -> Void = { _ in }) {
        guard let identifier = movie.identifier else {
            completion(.noAuth)
            return
        }
        
        let requestURL     = fireBaseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var request        = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting movie:\(error)")
            }
            completion(nil)
            }.resume()
    }
    
    func fetchMovie(with title: String, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        var movie: Movie? = nil
        context.performAndWait {
            do {
                movie = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching entry with title \(title):\(error)")
                movie = nil
            }
        }
        return movie
    }
    
    // Fetch ALL Movies From FireBase Server Method
    func fetchMoviesFromServer(completion: @escaping() -> Void) {
        
        let requestURL     = fireBaseURL.appendingPathExtension("json")
        var request        = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                NSLog("Error fetching movies from server:\(error)")
                completion()
                return
            }
            
            guard let data = data else {
                NSLog("Error GETing data for all movies")
                completion()
                return
            }
            
            do {
                let moviesDictionary = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
                let movieRepArray     = moviesDictionary.map({ $0.value })
                let moc               = CoreDataStack.shared.container.newBackgroundContext()
                
                self.updatePersistentStore(forMovieIn: movieRepArray, for: moc)
            } catch {
                NSLog("error decoding movies:\(error)")
            }
            completion()
        }.resume()
    }
}
