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
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    typealias CompletionHandler = (Error?) -> Void
    
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
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion(NSError())
                return
            }
            
            guard let data = data else {
                NSLog("No data returned by data movie")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                let moc = CoreDataStack.shared.container.newBackgroundContext()
                try self.updateMovies(with: movieRepresentations, context: moc)
                completion(nil)
            } catch {
                NSLog("Error decoding entry representations: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    private func updateMovies(with representations: [MovieRepresentation], context: NSManagedObjectContext) throws {
        var error: Error? = nil
        context.performAndWait {
            for movieRep in representations {
                guard let identifier = movieRep.identifier else { continue }
                
                if let movie = self.movie(forUUID: identifier, in: context) {
                    self.update(movie: movie, with: movieRep)
                } else {
                    let _ = Movies(movieRepresentation: movieRep, context: context)
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
    
    private func movie(forUUID uuid: UUID, in context: NSManagedObjectContext) -> Movies? {
        let fetchRequest: NSFetchRequest<Movies> = Movies.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        
        var results: Movies? = nil
        context.performAndWait {
            do {
                results = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching movie with uuid \(uuid): \(error)")
            }
        }
        return results
    }
    
    private func update(movie: Movies, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.identifier = representation.identifier
        movie.hasWatched = representation.hasWatched!
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
