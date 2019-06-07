//
//  MyMovies.swift
//  MyMovies
//
//  Created by Sameera Roussi on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String {
    case put = "PUT"
    case delete = "DELETE"
}

class MyMoviesController {
    
    // MARK: - Properties
    let baseURL = URL(string: "https://mymovies-20257.firebaseio.com/")!
    let jsonEncoder = JSONEncoder()
   
    
    // MARK: - CRUD
    
    // Crud = Create
    func put(_ movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        // Get the UUID identifier for this movie addition
        let identifier = movie.identifier ?? UUID()
        
        let moviesURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: moviesURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        do {
            guard let movieRepresentation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            request.httpBody = try jsonEncoder.encode(movieRepresentation)
            
        } catch {
            NSLog("Unable to encode MovieRepresentation \(error)")
            completion(error)
            return
        }
    }
    
    /* ======================================================================== */
    
    // cRud = Read (fetch)
    func fetchMovieListFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        
        let moviesURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: moviesURL) {(data, _, error) in
            if let error = error {
                NSLog("Error fetching my movie list from Firebase: \(error)")
            }
            
            guard let data = data else {
                NSLog("No movies have been saved yet ")
                completion(NSError())
                return
            }
            
             let jsonDecoder = JSONDecoder()
            do {
                let moviesRepresentations = try jsonDecoder.decode([String : MovieRepresentation].self, from: data)
                let movieListTweenie = Array(moviesRepresentations.values)
                
                try self.updateMovieList(with: movieListTweenie)
                completion(nil)
                
            } catch {
                NSLog("Error decoding Movies Representation \(error)")
                completion(error)
                return
            }
        }
        .resume()
    }

    /* ======================================================================== */
    
    // crUd
    func updateMovieList(with movieRepresentations: [MovieRepresentation]) throws {
        
        let mocInBackground = CoreDataStack.shared.container.newBackgroundContext()
        
        mocInBackground.performAndWait {
            for tempRep in movieRepresentations {
                guard let identifier = tempRep.identifier else { return }
                
                if let aMovie = getMovieFromCoreData(forUUID: identifier, context: mocInBackground) {
                    
                    // The movie is in Core Data store
                    aMovie.title = tempRep.title
                    aMovie.hasWatched = tempRep.hasWatched ?? false
                    
                } else {
                    let _ = Movie(movieRepresentation: tempRep, context: mocInBackground)
                }
            }
        }
        
        try CoreDataStack.shared.save(context: mocInBackground)
    } // updateMovieList func
        
    /* ======================================================================== */
    // cruD
    
    // MARK: - Additional functions
    
    // We can get the movie title
    func getMovieFromCoreData(forUUID uuid: UUID, context: NSManagedObjectContext) -> Movie? {
        
        var result: Movie? = nil
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching movie title with UUID \(uuid): \(error)")
            }
        }
        
        return result
        
    } //getTaskFromCoreData
    
} // class
