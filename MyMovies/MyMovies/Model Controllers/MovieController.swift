//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MovieController {
    
    init() {
        fetchMoviesFromServer()
    }
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching Task \(error)")
                completion(error)
                return
            }
            guard let data = data else {
                NSLog("No data returned by data task")
                completion(NSError())
                return
            }
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                
                // this below is the most seriously sized background task your project does, so it SHOULD get it's own concurrent context.
                let moc = CoreDataStack.shared.container.newBackgroundContext()
                
                try self.updateMovies(with: movieRepresentations, context: moc)
                completion(nil)
            } catch {
                NSLog("Error decoding task representations: \(error)")
                completion(error)
                return
            }
            }.resume()
    }
    
    private func updateMovies(with representations: [MovieRepresentation], context: NSManagedObjectContext) throws {
        
        var error: Error? = nil
        
        context.performAndWait {
            
            for movieRep in representations {
                guard let uuid = movieRep.identifier else {continue}
                if let movie = self.movie(forUUID: uuid, in: context) {
                    self.update(movie: movie, with: movieRep)
                } else {
                    let _ = Movie(movieRepresentation: movieRep, context: context)   //
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
    
    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched!
        
    }
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {

        
        // nil coalesce will certainly assign uuid = UUID() here
        let uuid = movie.identifier ?? UUID()
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")  //editor placeholder error, 10 minutes wasted: solution was command B
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            // put movie to be saved into temporary movieRepresentation instance, then save to CoreData
            guard var representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            representation.identifier = uuid
            //movie.identifier = uuid   might have to put this back in
            try saveToPersistentStore()
            
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding the movie \(movie): \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUT-ting movie to FireBase: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()           // saved movie should appear on FireBase HERE
    }
    
    func saveToPersistentStore() throws {
        
        let moc = CoreDataStack.shared.mainContext
        try moc.save() // write save method.  "errors thrown from here not handled" = inserted a bang!
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(response!) // avoids unwrapping it with if let response = response....
            completion(error)
            
            }.resume()
    }
    
    
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
    
    func toggleHasWatched(movie: Movie) {
        
        
    }
    
    // takes in an identifier and uses it to find that movie in CoreData
    func movie(forUUID uuid: UUID, in context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID) // identifier == uuid
        
        var result: Movie? = nil
        
        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching task with uuid: \(error)")
            }
        }
        return result
    }
    
    // MARK: - Properties
    
    typealias CompletionHandler = (Error?) -> Void
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://mymovies-8e4fd.firebaseio.com/")!
    
    var searchedMovies: [MovieRepresentation] = []
}
