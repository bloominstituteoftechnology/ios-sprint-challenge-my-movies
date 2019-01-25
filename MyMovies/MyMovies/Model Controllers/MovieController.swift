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
    typealias CompletionHandler = (Error?) -> Void
    private let firebaseURL = URL(string: "https://core-data-mymovies-project.firebaseio.com/")!
    
    //init() {
    //    fetchMoviesFromServer()
    //}
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from the data task.")
                completion(NSError())
                return
            }
            
            DispatchQueue.main.async {
                do {
                    var movieRepresentations: [MovieRepresentation] = []
                    movieRepresentations = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({$0.value})
                    
                    for movieRepresentation in movieRepresentations {
                        guard let identifier = movieRepresentation.identifier else { continue }
                        if let movie = self.fetchSingleMovieFromPersistentStore(identifier: identifier.uuidString) {
                            self.updateMovie(movie: movie, hasWatched: movie.hasWatched)
                        } else {
                            _ = Movie(movieRepresentation: movieRepresentation)
                        }
                    }
                    
                    self.saveToPersistentStore()
                    completion(nil)
                    
                } catch {
                    print("\nMovieController:\nLine: 56 \nError performing dataTask in fetchMoviesFromServer\n\(error)")
                }
            }
            }.resume()
    }
    
    
    func fetchSingleMovieFromPersistentStore(identifier: String) -> Movie? {
        let predicate = NSPredicate(format: "identifier == %@", identifier)
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = predicate
        let moc = CoreDataStack.shared.mainContext
        let movie = try? moc.fetch(fetchRequest)
        return movie?.first
    }
    
    func saveToPersistentStore(){
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            print("\nMovieController.swift\nError: Unable to save.\n\(error)")
        }
    }
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier
        if uuid == nil {
            movie.identifier = UUID()
            self.saveToPersistentStore()
        }
        
        
        let requestURL = firebaseURL.appendingPathComponent((movie.identifier?.uuidString)!).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        do {
            let body = try JSONEncoder().encode(movie)
            request.httpBody = body
        } catch {
            NSLog("\nError encoding movie:\n \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("\nError saving movie:\n \(error)")
            }
            completion(error)
            }.resume()
    }
    
    
    func createMovie(title: String) {
        let movie = Movie(context: CoreDataStack.shared.mainContext)
        movie.title = title
        put(movie: movie) { (_) in}
        saveToPersistentStore()
    }
    
    // Confusing myself...
    func updateMovie(movie: Movie, hasWatched: Bool?) {
        put(movie: movie) { (_) in}
        saveToPersistentStore()
    }
    
    
    func deleteMovie(movie: Movie) {
        deleteMovieFromServer(movie: movie) { (_) in}
        CoreDataStack.shared.mainContext.delete(movie)
        saveToPersistentStore()
    }
    
    func deleteMovieFromServer(movie: Movie, completionHandler: @escaping CompletionHandler) {
        let requestURL = firebaseURL.appendingPathComponent((movie.identifier?.uuidString)!).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("\nError deleting journal entry:\n \(error)")
            }
            completionHandler(error)
            }.resume()
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
                self.searchedMovies = movieRepresentations
                completion(nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    
}
