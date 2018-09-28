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
    
    // MARK: - Initializer
    
    init(){
        fetchFromServer()
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    typealias CompletionHandler = (Error?) -> Void
    
    // MARK: - BaseURL & APIkey
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let baseURL2 = URL(string: "https://mymovie-ilqarilyasov.firebaseio.com/")!
    
    // MARK: - GET searchTerm
    
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


extension MovieController {
    
    // CRUD functions
    
    func createMovie(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        let movie = Movie(title: movieRepresentation.title)
        
        do {
           try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error creating a movie: \(error)")
        }
        
        putMovieToServer(movie: movie)
        
    }
    
    func updateWatchStatus(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        movie.hasWatched = !movie.hasWatched
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error updating movie watch status: \(error)")
        }
        
        putMovieToServer(movie: movie)
    }
    
    func deleteMovie(movie: Movie) {
        
        deleteMovieFromServer(movie: movie)
        
        let moc = CoreDataStack.shared.mainContext
        do {
            moc.delete(movie)
            try moc.save()
        } catch {
            moc.reset()
            NSLog("Error deleting movie: \(error)")
        }
    }
    
    // MARK: - Persistent Store
    
    func updateMovie(movie: Movie, movieRepresentation mr: MovieRepresentation) {
        guard let id = mr.identifier?.uuidString,
            let hasWatched = mr.hasWatched else {return}
        
        movie.title = mr.title
        movie.identifier = id
        movie.hasWatched = hasWatched
    }
    
    func fetchMovieFromPersistentStore(identifier id: String, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "identifier == %@", id)
        fetchRequest.predicate = predicate
        
        var entry: Movie?
        
        context.performAndWait {
            do {
                entry = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching a movie: \(error)")
            }
        }
        return entry
    }
    
    // MARK: - Firebase PUT, DELETE, GET
    
    func putMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let id = movie.identifier else { completion(NSError()); return }
        
        let url = baseURL2.appendingPathComponent(id).appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put.rawValue
        
        do {
            let movieData = try JSONEncoder().encode(movie)
            request.httpBody = movieData
            completion(nil)
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error puttind movie to the server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }){
        guard let id = movie.identifier else {completion(NSError()); return }
        
        let url = baseURL2.appendingPathComponent(id).appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting data: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func fetchFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let url = baseURL2.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching moview: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned")
                completion(error)
                return
            }
            
            var movieRepresentations = [MovieRepresentation]()
            do {
                movieRepresentations = try JSONDecoder().decode([String:MovieRepresentation].self, from: data).map { $0.value }
            } catch {
                NSLog("Error decoding data: \(error)")
                completion(error)
                return
            }
            
            let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
            
            backgroundContext.performAndWait {
                for movieRepresentation in movieRepresentations {
                    guard let id = movieRepresentation.identifier?.uuidString else { return }
                    let movie = self.fetchMovieFromPersistentStore(identifier: id, context: backgroundContext)
                    
                    if let movie = movie, movie != movieRepresentation {
                        self.updateMovie(movie: movie, movieRepresentation: movieRepresentation)
                    } else if movie == nil {
                        _ = Movie(movieRepresentation: movieRepresentation, context: backgroundContext)
                    }
                }
                do {
                    try CoreDataStack.shared.save(context: backgroundContext)
                } catch {
                    NSLog("Error comparing movie to movieRepresentation: \(error)")
                }
            }
            
        }.resume()
    }
}
