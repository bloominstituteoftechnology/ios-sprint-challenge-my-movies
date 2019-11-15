//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData


enum HttpMethod: String {
    case put = "PUT"
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
}

class MovieController {
    
    //MARK: - Properties
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let databaseURL = URL(string:"https://mymovies-9f7f0.firebaseio.com/")!
    var searchedMovies: [MovieRepresentation] = []
    //MARK: - Initializers
    
    init() {
        // fetch from server
        fetchFromFireBase()
    }
    
    //MARK: - crud methods
    
    func addMovie(withTitle title: String, context: NSManagedObjectContext) {
        let movie = Movie(title: title, context: CoreDataTask.shared.context)
        put(movie)
        CoreDataTask.shared.context.saveChanges()
    }
    
    func deleteMovie( _ movie: Movie) {
        CoreDataTask.shared.context.delete(movie)
        
    }
    
    func updateMovie(_ movie: Movie) {
        movie.hasBeenWatched = !movie.hasBeenWatched
        put(movie)
        CoreDataTask.shared.context.saveChanges()
    }
    
    // MARK: - Database methods
    
    ///update Movies from servers
    func update(_ movieRepresentations: [MovieRepresentation]) {
        let fetchedIdentifiers = movieRepresentations.map({$0.identifier})
        let movieRepId = Dictionary(uniqueKeysWithValues: zip(fetchedIdentifiers, movieRepresentations))
        var moviesToBeCreated = movieRepId
        
        let backgroundContext = CoreDataTask.shared.container.newBackgroundContext()
        
        backgroundContext.performAndWait {
                do {
                    let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "identifier IN %@", fetchedIdentifiers)
                    let existingMovies = try backgroundContext.fetch(fetchRequest)
                        
                    for movie in existingMovies {
                            
                    guard let identifier = movie.identifier,
                    let movieRepresentation = movieRepId[identifier] else {continue}
                    movie.hasBeenWatched = movieRepresentation.hasWatched ?? false
                    movie.title = movieRepresentation.title
                    moviesToBeCreated.removeValue(forKey: identifier)
                        
                }
                    for movieRep in moviesToBeCreated.values {
                        Movie(movieRep: movieRep, context: backgroundContext)
                        }
                        
                    CoreDataTask.shared.context.saveContext(context: backgroundContext)
                    } catch {
                        NSLog("error fetching from persistence store: \(error.localizedDescription)")
                    }
        }
    }

    /// Put on movie on server
    private func put(_ movie: Movie) {
        let movieIdentifier = movie.identifier ?? UUID()
        movie.identifier = movieIdentifier
        
        let firebaseURL = databaseURL.appendingPathComponent(movieIdentifier.uuidString).appendingPathExtension("json")
         var request = URLRequest(url: firebaseURL)
             request.httpMethod = HttpMethod.post.rawValue
        do {
            request.httpBody = try JSONEncoder().encode(movie.movieRep)
         } catch {
             NSLog("failed to put film on database")
         }
         
        URLSession.shared.dataTask(with: request) { (_, response, error) in
             guard let response = response as? HTTPURLResponse,
                 (200...299).contains(response.statusCode) else {return}
             
             if let error = error {
                 NSLog("failed to put in database: \(error.localizedDescription)")
             }
         }.resume()
    }
    
    /// delete movie from server
    private func delete(_ movie: Movie, completion: @escaping() ->Void = {}) {
        guard let identifier = movie.identifier else { return }
        
        let firebaseURL =  databaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: firebaseURL)
        request.httpMethod = HttpMethod.delete.rawValue
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error as NSError? {
                NSLog("error deleteing from server: \(error.localizedDescription)")
                completion()
            }
        }.resume()
    }
    
    /// fetch movies from server
    private func fetchFromFireBase(completion: @escaping()-> Void = {}){
        let firebaseURL = databaseURL.appendingPathExtension("json")
        let request = URLRequest(url: firebaseURL)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {return}
            if let error = error as NSError? {
                NSLog("error loading from server: \(error.localizedDescription)")
                completion()
            }
            
            guard let data = data else { return completion()}
            
            do {
                let jsonDecoder = JSONDecoder()
                let movies = try jsonDecoder.decode([String: MovieRepresentation].self, from: data).map({$0.value})
                 self.update(movies)
            } catch {
                NSLog("error decoding data: \(error.localizedDescription)")
                completion()
            }
        }.resume()
    }
}

// MARK: - extension for movie api
extension MovieController {
    
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
