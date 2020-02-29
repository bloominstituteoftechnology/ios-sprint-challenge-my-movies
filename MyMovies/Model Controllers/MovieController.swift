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
    
    init() {
        fetchMovies()
    }
    
    // MARK: - Properties
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let fireBaseURL = URL(string: "https://movies-df593.firebaseio.com/")!
    
    var searchedMovies: [MovieRepresentation] = []
    
    typealias CompletionHandler = (Error?) -> Void
    
    // MARK: - Movie Search Method
    
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
    
    // MARK: - Firebase Methods
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let identifier = movie.identifier ?? UUID()
        
        let requestURL = fireBaseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard let movieRepresentation = movie.movieRepresentation else {
            NSLog("There is no movie representation")
            completion(NSError())
            return
        }
        
        do {
            let movieData = try JSONEncoder().encode(movieRepresentation)
            request.httpBody = movieData
        } catch {
            NSLog("Error enconding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                NSLog("Error sending movie to Firebase: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = fireBaseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting movie from Firebase: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    func update(movie: Movie, with representation: MovieRepresentation) {
        guard let hasWatched = representation.hasWatched else { return }

        movie.title = representation.title
        movie.hasWatched = hasWatched
        movie.identifier = representation.identifier
    }
    
    func updateMovies(with representations: [MovieRepresentation]) {
        let identifiersToFetch = representations.compactMap { $0.identifier }
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var moviesToCreate = representationsByID

        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)

        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.performAndWait {
            do {
                let existingMovies = try context.fetch(fetchRequest)

                for movie in existingMovies {
                    guard let identifier = movie.identifier,
                        let represesentation = representationsByID[identifier] else { continue }

                    update(movie: movie, with: represesentation)
                    moviesToCreate.removeValue(forKey: identifier)
                }

                for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }

                CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error fetching movies from Firebase: \(error)")
            }
        }
    }

    func fetchMovies(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = fireBaseURL.appendingPathExtension("json")

        URLSession.shared.dataTask(with: requestURL) { data, _, error in
            if let error = error {
                NSLog("Error fetching movies from Firebase: \(error)")
                completion(error)
                return
            }

            guard let data = data else {
                NSLog("Error getting data from Firebase")
                completion(NSError())
                return
            }

            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                self.updateMovies(with: movieRepresentations)
            } catch {
                NSLog("Error decoding movie representations: \(error)")
                completion(error)
                return
            }

            completion(nil)
        }.resume()
    }
    
    // MARK: - Core Data Methods
    
    func updateMovie(movie: Movie, called title: String, hasWatched: Bool, identifier: UUID) {
        movie.title = title
        movie.hasWatched = hasWatched
        movie.identifier = identifier
        put(movie: movie)
        CoreDataStack.shared.save()
    }
    
    func deleteMovie(movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        deleteMovieFromServer(movie: movie)
        CoreDataStack.shared.save()
    }
    
    // MARK: - Movie State Methods
    
    func saveMovie(movieRepresentation: MovieRepresentation) {
        guard let movie = Movie(movieRepresentation: movieRepresentation) else { return }
        put(movie: movie)
        CoreDataStack.shared.save()
    }
    
    func watchedMovie(_ movie: Movie) {
        movie.hasWatched.toggle()
        
        put(movie: movie)
        CoreDataStack.shared.save()
    }
}
