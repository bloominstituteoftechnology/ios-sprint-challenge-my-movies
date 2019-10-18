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
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

class MovieController {
    
    var searchedMovies: [MovieRepresentation] = []
    
    private let fireBase = URL(string: "https://movies-e6a60.firebaseio.com/")!
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    init() {
        fetchMoviesFromServer()
    }
    
    func createMovie(with title: String, identifier: UUID, hasWatched: Bool) {
        let movie = Movie(title: title, hasWatched: hasWatched, identifier: identifier)
        put(movie: movie)
        CoreDataStack.shared.save()
    }
    
    func update(movie: Movie, title: String, hasWatched: Bool) {
        
        movie.title = title
        movie.hasWatched = hasWatched
        
        put(movie: movie)
        
        CoreDataStack.shared.save()
    }
    
    func delete(movie: Movie) {
        
        CoreDataStack.shared.mainContext.delete(movie)
        deleteMovieFromServer(movie: movie)
        CoreDataStack.shared.save()
    }
    
    private func put(movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        
        let requestURL = fireBase.appendingPathComponent(movie.identifier?.uuidString ?? UUID().uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard let title = movie.title else { return }
        let rep = MovieRepresentation(title: title, identifier: movie.identifier, hasWatched: movie.hasWatched)
        
        do {
            
            request.httpBody = try JSONEncoder().encode(rep)
        } catch {
            NSLog("Error encoding Movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting Movie to server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        
        guard let identifier = movie.identifier else {
            NSLog("Movie identifier is nil")
            completion(NSError())
            return
        }
        
        let requestURL = fireBase.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error deleting movie from server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    func fetchMoviesFromServer(completion: @escaping () -> Void = { }) {
        let requestURL = fireBase.appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion()
            }
            
            guard let data = data else {
                NSLog("No data returned from data movies")
                completion()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let representations = try decoder.decode([String: MovieRepresentation].self, from: data).map({ $0.value })
                
                self.updateMovies(with: representations)
                CoreDataStack.shared.save()
                
            } catch {
                NSLog("Error decoding: \(error)")
            }
            
        }.resume()
    }
    
    private func updateMovies(with representations: [MovieRepresentation]) {
        let moviesWithID = representations.filter({ $0.identifier != nil })
        let identifiersToFetch = moviesWithID.compactMap({ UUID(uuidString: $0.identifier!.uuidString) })
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
        
        var moviesToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            
            do {
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let identifier = movie.identifier,
                        let representation = representationsByID[identifier] else { continue }
                    self.update(movie: movie, with: representation)
                    
                    moviesToCreate.removeValue(forKey: identifier)
                }
                
                for representation in moviesToCreate.values {
                    Movie(movieRep: representation, context: context)
                }
                
            } catch {
                NSLog("Error fetching tasks for UUIDs: \(error)")
            }
            
            CoreDataStack.shared.save(context: context)
        }
    }
    
    private func update(movie: Movie, with movieRep: MovieRepresentation) {
        movie.title = movieRep.title
        movie.hasWatched = movieRep.hasWatched ?? false
        movie.identifier = movieRep.identifier
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
