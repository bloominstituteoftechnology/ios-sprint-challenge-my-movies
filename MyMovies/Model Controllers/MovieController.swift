//
//  MovieController.swift
//  MyMovies
//
//  Sal 
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData


class MovieController {
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    let firebaseURL = URL(string: "https://newmovies-4f3f2.firebaseio.com/")!
//    let myMovieController = MyMovieController()
    
    static let sharedInstance = MovieController() // shared isntance of controller
    
    
    // clear search
    func clearSearchForMovies() {
        searchedMovies = []
    }
    
    // Search Function for API
    
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
    
    typealias CompletionHandler = (Error?) -> Void
    
   // fetch movies from controller
        init() {
            fetchMoviesFromServer()
        }
     
    
        // fetch movies from firebase
        func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
            let requestURL = firebaseURL.appendingPathExtension("json")
            URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
                guard error == nil else {
                    print("Error fetching movies: \(error!)")
                    DispatchQueue.main.async {
                        completion(error)
                    }
                    return
                }
                guard let data = data else {
                    print(" No Data returned by data task")
                    DispatchQueue.main.async {
                        completion(NSError())
                    }
                    return
                }
                do {
                    let movieRepresentation = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                    //update Movies
                    try self.updateMovies(with: movieRepresentation)
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                    print("Error Decoding task with representation: \(error)")
                }
            }.resume()
        }
    
    // Send Movies to Firebase Database ( PUT )
    
    func sendMoviesToServer(movie: Movie, completion: @escaping CompletionHandler = {_ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var representation = movie.movieRepresentation else { completion(NSError())
            return }
            representation.identifier = uuid
            movie.identifier = uuid
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
            request.httpBody = try JSONEncoder().encode(representation)
            
        } catch {
            print("Error encoding Movie \(movie): \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard error == nil else {
            print("Error PUTing tasks to server: \(error!)")
            DispatchQueue.main.async {
                completion(error)
            }
            return
        }
        DispatchQueue.main.async {
            completion(nil)
        }
        }.resume()
    }
    
    
    //delete movies from FireBase Database

    func deleteMoviesFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error ) in
            guard error == nil else {
                print("Error deleting movie: \(error!)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
        
        // Update Movies in firebase
        func updateMovies(with representations: [MovieRepresentation]) throws {
            let moviesWithID = representations.filter { $0.identifier != nil }
            let identifierToFetch = moviesWithID.compactMap { $0.identifier }
            let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifierToFetch, moviesWithID))
            var moviesToCreate = representationsByID
            
            let fetchRequest : NSFetchRequest<Movie> = Movie.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifierToFetch)
            
            let context = CoreDataStack.shared.container.newBackgroundContext()
            
            context.perform {
                do {
                    let existingMovies = try context.fetch(fetchRequest)
                    for movie in existingMovies {
                        guard let id = movie.identifier,
                            let representation = representationsByID[id] else { continue }
                        self.update(movie: movie, with: representation)
                        moviesToCreate.removeValue(forKey: id)
                    }
                    for representation in moviesToCreate.values {
                        Movie(movieRepresentation: representation, context: context)
                    }
                } catch {
                    print("Error fetching Movies for UUIDs: \(error)")
                }
                do {
                    try CoreDataStack.shared.save(context: context)
                } catch {
                    print("Error saving to database")
                }
            }
        }
        
        // update
        private func update(movie: Movie, with representation: MovieRepresentation) {
            movie.title = representation.title
    //        movie.identifier = representation.identifier // dont need identifier
            movie.hasWatched = representation.hasWatched ?? false
        }
    
    // create new saved movie
    func createSavedMovie(title: String) {
        let movie = Movie(title: title)
        sendMoviesToServer(movie: movie)
        do {
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
        } catch {
            print("Error saving movie object: \(error)")
        }
        
    }
        
        
    
    // has watched or not watched movie BOOL
    func hasWatchedMovie(for movie: Movie) {
        movie.hasWatched.toggle()
        sendMoviesToServer(movie: movie)
        do {
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
        } catch {
            print("error saving selection of movie \(error)")
        }
    }
    
    // delete movie from list
    func delete(for movie: Movie) {
        deleteMoviesFromServer(movie)
        let context = CoreDataStack.shared.mainContext
        do {
            context.delete(movie)
            try CoreDataStack.shared.save(context: context)
        } catch {
            context.reset()
            print("Error deleting movie object from MOC: \(error)")
        }
    }
    

    
    
}
