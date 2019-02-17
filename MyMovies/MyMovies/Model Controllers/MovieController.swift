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
    
    // MARK: - Properties
    var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebasebaseURL = URL(string: "https://awesome-c0782.firebaseio.com/")!

    init() {
        fetchMoviesFromServer()
    }
    
    func movie(for uuid: UUID, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        
        var movie: Movie?
        
        context.performAndWait {
            do {
                movie = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching movie with \(uuid): \(error)")
            }
        }
        return movie
    }
    
    func update(_ movie: Movie, title: String, hasWatched: Bool?) {
        guard let hasWatched = hasWatched else { return }
        
        movie.title = title
        movie.hasWatched = hasWatched
        
    }
    
    func create(title: String) {
        let movie = MovieRepresentation(title: title)
        
        put(movie)
    }
    
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        
        let url = firebasebaseURL.appendingPathExtension("json")
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let movieRepresentations = try jsonDecoder.decode([String: MovieRepresentation].self, from: data)
                
                let backgroundMoc = CoreDataStack.shared.container.newBackgroundContext()
                
                backgroundMoc.performAndWait {
                    
                    for (_, movieRep) in movieRepresentations {
                        
                        guard let identifier = movieRep.identifier else { return }
                        
                        if let movie = self.movie(for: identifier, context: backgroundMoc) {
                            self.update(movie, title: movieRep.title, hasWatched: movieRep.hasWatched)
                            
                        } else {
                            Movie(movieRepresentation: movieRep, context: backgroundMoc)
                        }
                    }
                    
                    do {
                        try CoreDataStack.shared.save(context: backgroundMoc)
                    } catch {
                        NSLog("Error saving background context: \(error)")
                    }
                }
                
                completion(nil)
                
            } catch {
                NSLog("error decoding MovieRepresentations: \(error)")
                completion(error)
            }
            }.resume()
    }
    
    func put(_ movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        let identifier = movie.identifier ?? UUID()
        
        let url = firebasebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        guard let movieRepresentation = movie.movieRepresentation else {
            NSLog("Unable to convert movie to movierepresentation")
            completion(NSError())
            return
        }
        
        let encoder = JSONEncoder()
        
        do {
            let movieJSON = try encoder.encode(movieRepresentation)
            
            request.httpBody = movieJSON
        } catch {
            NSLog("unable to encode movie representation: \(error)")
            completion(error)
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error putting movie to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    func delete(_ movie: Movie, completion: @escaping (Error?) -> Void = { _ in}) {
        guard let identifier = movie.identifier else {
            completion(NSError())
            return
        }
        
        let url = firebasebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                NSLog("Error deleting movie: \(error)")
                completion(error)
            }
            completion(nil)
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
}
