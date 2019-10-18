//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

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
    
    // FIREBASE
    let fireBaseURL = URL(string: "https://mymovies-4a993.firebaseio.com/")!
    
    init() {
        fetchMoviesFromServer()
    }
    
    func fetchMoviesFromServer(completion: @escaping () -> Void = { }) {
        
        let requestURL = fireBaseURL.appendingPathExtension("json")
        
        let request = URLRequest(url: requestURL)
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion()
                return
            }
            
            guard let data = data else {
                NSLog("No data return from movie fetch data task")
                completion()
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let movies = try decoder.decode([String: MovieRepresentation].self, from: data).map({ $0.value })
                self.updateMovies(with: movies)
            } catch {
                NSLog("Error decoding MovieRepresentation: \(error)")
            }
            completion()
        }.resume()
    }
    
    func updateMovies(with representations: [MovieRepresentation]) {
        
        let identifiersToFetch = representations.map({ $0.identifier })
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        
        var moviesToCreate = representationsByID
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            
            do {
                let fetchRequest: NSFetchRequest<MyMovies> = MyMovies.fetchRequest()
                
                fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
                
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    
                    guard let identifier = movie.identifier,
                        let representation = representationsByID[identifier]
                        else { continue }
                    
                    movie.title = representation.title
                    movie.hasWatched = representation.hasWatched!
                    
                    moviesToCreate.removeValue(forKey: identifier)
                }
                
                for representation in moviesToCreate.values {
                    MyMovies(movieRepresentation: representation, context: context)
                }
                
                CoreDataStack.shared.save(context: context)
                
            } catch {
                NSLog("Error fetching entries from persistent store: \(error)")
            }
        }
    }
    
    func put(movie: MyMovies, completion: @escaping () -> Void = { }) {
        
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard let movieRepresentation = movie.movieRepresentation else {
            NSLog("Movie Representation is nil")
            completion()
            return
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            NSLog("Error encoding movie representation: \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            
            if let error = error {
                NSLog("Error PUTting task: \(error)")
                completion()
                return
            }
            completion()
        }.resume()
    }
    
    func deleteMovieFromServer(movie: MyMovies, completion: @escaping () -> Void = { }) {
        
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            
            if let error = error {
                NSLog("Error DELETEing entry: \(error)")
                completion()
                return
            }
            completion()
        }.resume()
    }
    
    func createMovie(with title: String, hasWatched: Bool, context: NSManagedObjectContext) {
        
        let movie = MyMovies(title: title, hasWatched: hasWatched, context: context)
        CoreDataStack.shared.save(context: context)
        put(movie: movie)
    }
    
    func updateMovie(movie: MyMovies, hasWatched: Bool, context: NSManagedObjectContext) {
        
        movie.hasWatched = hasWatched
        CoreDataStack.shared.save(context: context)
        put(movie: movie)
    }
    
    func deleteMovie(movie: MyMovies, context: NSManagedObjectContext) {
        
        deleteMovieFromServer(movie: movie)
        CoreDataStack.shared.mainContext.delete(movie)
        CoreDataStack.shared.save(context: context)
    }
}
