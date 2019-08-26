//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

typealias CompletionHandler =  (Error?) -> Void

class MovieController {
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(NSError())
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error searching for movie with search term \(searchTerm): \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = try JSONDecoder().decode(MovieRepresentations.self, from: data).results
                self.searchedMovies = movieRepresentations
                completion(nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(error)
            }
            }.resume()
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    let firebaseURL = URL(string: "https://movie-sprint.firebaseio.com/")!
}

extension MovieController {
    
    //MARK: My Functions ***
    //Crud
    func createMovie(withTitle title: String) {
        let movie = Movie(title: title)
        do {
            try CoreDataStack.shared.save()
            put(movie: movie)
        } catch {
            
            NSLog("Error creating movie: \(movie)")
        }
    }
    
    func updateHasWatched(for movie: Movie) {
        movie.hasWatched = !movie.hasWatched
        do {
            try CoreDataStack.shared.save()
            put(movie: movie)
        } catch {
            NSLog("Error updating movie: \(movie)")
        }
    }
    
    func updateMovie(withMovie movie: Movie, withTitle title: String) {
        movie.title = title
        do {
            try CoreDataStack.shared.save()
            put(movie: movie)
        } catch {
            NSLog("Error updating movie: \(movie)")
        }
    }
    
    func deleteMovie(withMovie movie: Movie) {
        self.deleteMovieFromServer(movie) { (error) in
            DispatchQueue.main.async {
                let moc = CoreDataStack.shared.mainContext
                moc.delete(movie)
                
                do {
                    try moc.save()
                } catch {
                    NSLog("Error saving after delete method")
                }
            }
        }
    }
}

//MARK: Network Functions
extension MovieController {
    
    func fetchEntrysFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                
                NSLog("Error fetching tasks: \(error)")
                completion(error)
                
                return
            }
            
            guard let data = data else { NSLog("No data returned by the data task"); completion(error); return }
            
            do {
                
                let movieReps = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                let moc = CoreDataStack.shared.mainContext
                try self.updateMovies(with: movieReps, context: moc)
                
                completion(nil)
                
            } catch {
                
                NSLog("Error decoding movie representations: \(error)")
                completion(error)
                return
                
            }
            }.resume()
    }
    
    func fetchSingleMovieFromPersistentStore(forUUID uuid: String, in context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid)
        
        var result: Movie? = nil
        context.performAndWait {
            do {
                
                result = try context.fetch(fetchRequest).first
                
            } catch {
                
                NSLog("Error fetching movie with uuid \(uuid): \(error)")
            }
        }
        
        return result
    }
    
    func update(movie: Movie, with representation: MovieRepresentation, context: NSManagedObjectContext) {
        movie.title = representation.title
    }
    
    func updateMovies(with representations: [MovieRepresentation], context: NSManagedObjectContext) throws {
        var error: Error? = nil
        
        context.performAndWait {
            for movieRep in representations {
                if let identifier = movieRep.identifier {
                    
                    if let movie = self.fetchSingleMovieFromPersistentStore(forUUID: identifier.uuidString, in: context) {
                        
                        self.update(movie: movie, with: movieRep, context: context)
                        
                    } else {
                        
                        let _ = Movie(movieRepresentation: movieRep, context: context)
                    }
                }
            }
            
            do {
                try context.save()
                
            } catch let saveError {
                
                error = saveError
            }
        }
        if let error = error { throw error }
    }
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        let uuid = movie.identifier ?? UUID()
        
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        guard var representation = movie.movieRepresentation else { completion(NSError()); return }
        
        do {
            representation.identifier = uuid
            movie.identifier = uuid
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTing task to server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            }.resume()
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            print(response!)
            completion(error)
            }.resume()
    }
}

