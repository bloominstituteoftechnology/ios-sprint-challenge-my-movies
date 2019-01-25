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
        fetchMoviesFromServer(context: CoreDataStack.shared.mainContext)
    }
    
    func saveToPersistentStore() {
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            fatalError("Can't save Data \(error)")
        }
        
    }
    
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
                print(movieRepresentations)
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
    
    
    func create(title: String, hasWatched: Bool?, timestamp: Date, identifier: UUID?) {
        
        let newMovie = Movies(context: CoreDataStack.shared.mainContext)
        
        
        newMovie.title = title
        newMovie.hasWatched = false
        newMovie.timestamp = Date()
        newMovie.identifier = identifier ?? UUID()
        put(movie: newMovie)
        saveToPersistentStore()
    }
    
    func update(movie: Movies, title: String, hasWatched: Bool, timestamp: Date) {
        
        movie.title = title
        movie.hasWatched = hasWatched
        movie.timestamp = Date()
        put(movie: movie)
        saveToPersistentStore()
    }
    func delete(movie: Movies) {
        deleteMovieFromServer(movie: movie)
        CoreDataStack.shared.mainContext.delete(movie)
        saveToPersistentStore()
    }
    
    
    typealias ComplitionHandler = (Error?) -> Void
    
    private let firebaseURL = URL(string: "https://mymovies-sprint4.firebaseio.com/")!
    
    
    func put(movie: Movies, comletion: @escaping ComplitionHandler = { _ in }){
        
        
        let uuid = movie.identifier
        
        let requestURL = firebaseURL.appendingPathComponent((uuid?.uuidString)!).appendingPathExtension("json")
        
        print(requestURL)
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movie)
        } catch {
            NSLog("Unable to encode \(movie): \(error)")
            comletion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("No fetching tasks \(error)")
                comletion(error)
            }
            }.resume()
    }
    func deleteMovieFromServer(movie: Movies, complition : @escaping ComplitionHandler = {  _ in}) {
        
        let URL = firebaseURL.appendingPathComponent((movie.identifier?.uuidString)!).appendingPathExtension("json")
        
        var request = URLRequest(url: URL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Errorsaving task \(error)")
            }
            complition(error)
            }.resume()
    }
    
    func updateMovies(toMovies: Movies, fromMovieRepresentation: MovieRepresentation) {
        
        guard let context = toMovies.managedObjectContext else { return }
        
        context.perform {
            
            guard toMovies.identifier == fromMovieRepresentation.identifier else {
                fatalError("Updating the wrong task")
            }
            
            toMovies.title = fromMovieRepresentation.title
            toMovies.hasWatched = fromMovieRepresentation.hasWatched ?? false
            toMovies.timestamp = Date()
            
            
        }
    }
    
    func fetchSingleMovieFromPersistentStore(movieIdentifier: String, context: NSManagedObjectContext) -> Movies? {
        let predicate = NSPredicate(format: "identifier == %@", movieIdentifier)
        let fetchRequest: NSFetchRequest<Movies> = Movies.fetchRequest()
        fetchRequest.predicate = predicate
        
        // let moc = CoreDataStack.shared.mainContext
        var movie: Movies?
        
        context.performAndWait {
            movie = (try? context.fetch(fetchRequest))?.first
        }
        
        return movie
    }
    
    func fetchMoviesFromServer(context: NSManagedObjectContext, complition: @escaping ComplitionHandler = { _ in }) {
        
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        
        
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("No fetching tasks \(error)")
                complition(error)
                return
            }
            guard let data = data else {
                NSLog("No data")
                complition(NSError())
                return
            }
            
            DispatchQueue.main.async {
                
                do {
                    var movieRepresentations: [MovieRepresentation] = []
                    movieRepresentations = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({$0.value})
                    print(movieRepresentations)
                    for movieRepresentation in movieRepresentations {
                        guard let identifier = movieRepresentation.identifier?.uuidString else { continue }
                        if let movie = self.fetchSingleMovieFromPersistentStore(movieIdentifier: identifier, context: context) {
                            self.updateMovies(toMovies: movie, fromMovieRepresentation: movieRepresentation)
                        } else {
                            context.perform {
                                
                                _ = Movies(movieRepresentation: movieRepresentation, context: context)
                            }
                        }
                    }
                    
                    self.saveToPersistentStore()
                    try! context.save()
                    complition(nil)
                    
                } catch {
                    NSLog("Error")
                    complition(error)
                }
            }
            
            }.resume()
    }
    
    
    
    
}
