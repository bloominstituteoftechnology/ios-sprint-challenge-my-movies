//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class MovieController {
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://movies-df593.firebaseio.com/")!
    
    typealias CompletionHandler = (Error?) -> Void
    
    func searchForMovie(with searchTerm: String, completion: @escaping CompletionHandler) {
        
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
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movies from server: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            guard let data = data else {
                NSLog("No data from data task")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let movieRepresentations = try decoder.decode([String : MovieRepresentation].self, from: data).map({ $0.value })
                self.updateMovies(with: movieRepresentations)
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                NSLog("Error decoding movie representations: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func deleteFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let identifier = movie.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = firebaseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue

        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting movie: \(error)")
            }
            
            DispatchQueue.main.async {
                completion(error)
            }
        }.resume()
    }
    
    func updateMovies(with representations: [MovieRepresentation]) {
        let identifiersToFetch = representations.compactMap({ $0.identifier })
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var moviesToCreate = representationsByID
        
            let context = CoreDataStack.shared.container.newBackgroundContext()
        context.performAndWait {
            do {
                let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
                
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let identifier = movie.identifier,
                        let representation = representationsByID[identifier] else { continue }
                    
                    movie.title = representation.title
                    movie.hasWatched = representation.hasWatched ?? false
                    
                    moviesToCreate.removeValue(forKey: identifier)
                }
                
                for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
                
                CoreDataStack.shared.save(context: context)
            } catch {
                
            }
        }
    }
    
    func put(movie: Movie, completion: @escaping () -> Void = { }) {
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = firebaseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard let movieRepresentation = movie.movieRepresentation else {
            NSLog("Error with request URL")
            completion()
            return
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error  with data task: \(error)")
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }.resume()
    }
    
    @discardableResult func createMovie(called title: String, hasWatched: Bool, context: NSManagedObjectContext) -> Movie {
        let movie = Movie(title: title, context: context)
        put(movie: movie)
        
        CoreDataStack.shared.save()
        
        return movie
    }
    
    func updateMovie(movie: Movie, called title: String, hasWatched: Bool) {
        movie.title = title
        movie.hasWatched = hasWatched
        put(movie: movie)
        
        CoreDataStack.shared.save()
    }
    
    func delete(movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        CoreDataStack.shared.save()
    }
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
