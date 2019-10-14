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
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://mymovies-c61e8.firebaseio.com/")!
    
    func syncFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error fetching movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                print("No data returned by data")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let dictionaryOfMovies = try decoder.decode([String: MovieRepresentation].self, from: data)
                let movieRepresentations = Array(dictionaryOfMovies.values)
                try self.updateMovies(with: movieRepresentations)
                completion(nil)
            } catch {
                print("Error decoding movie representations: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    func updateMovies(with representations: [MovieRepresentation]) throws {
        let moviesWithID = representations.filter({ $0.identifier != nil })
        let identifiersToFetch = moviesWithID.compactMap({ $0.identifier })
        let representationByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
        
        var moviesToCreate = representationByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        // this is bg context so it's fine without waiting
        context.perform {

            do {
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationByID[id] else {
                            continue
                    }
                    
                    movie.title = representation.title
                    movie.hasWatched = representation.hasWatched ?? false
                    
                    moviesToCreate.removeValue(forKey: id)
                }
                
                for representation in moviesToCreate.values {
                    let _ = Movie(movieRepresentation: representation, context: context)
                }
            } catch {
                print("Error fetching movies for UUIDs: \(error)")
            }
        }
        
        try CoreDataStack.shared.save(context: context)
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
    
    func saveMovie(movieRepresentation: MovieRepresentation) {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title = %@", movieRepresentation.title)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.perform {
            do {
                let existingMovies = try context.fetch(fetchRequest)
                if existingMovies.isEmpty {
                    let movie = Movie(movieRepresentation: movieRepresentation)
                    try CoreDataStack.shared.save(context: context)
                    
                    self.put(movie: movie)
                }
            } catch {
                print("Error fetching movies: \(error)")
            }
        }
    }
    
    func toggleHasWatched(movie: Movie) {
        guard let context = movie.managedObjectContext else {
            return
        }
        
        context.performAndWait {
            do {
                movie.hasWatched.toggle()
                try CoreDataStack.shared.save(context: context)
                
                put(movie: movie)
            } catch {
                print("Error saving movie object: \(error)")
            }
        }
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    func put(movie: Movie, completion: @escaping () -> Void = { }) {
        let uuid = movie.identifier ?? UUID()
        
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        guard let context = movie.managedObjectContext else {
            completion()
            return
        }
        
        context.performAndWait {
            do {
                guard var representation = movie.movieRepresentation else {
                    completion()
                    return
                }
                representation.identifier = uuid
                movie.identifier = uuid
                
                try CoreDataStack.shared.save(context: context)
                
                request.httpBody = try JSONEncoder().encode(representation)
            } catch {
                NSLog("Error encoding \(movie): \(error)")
                completion()
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error PUTting entry to server: \(error)")
                completion()
                return
            }
            completion()
        }.resume()
    }
    
    func delete(movie: Movie) {
        let uuid = movie.identifier!.uuidString
        let requestURL = firebaseURL.appendingPathComponent(uuid).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error DELETEing entry to server: \(error)")
                return
            }
        }.resume()
        
        guard let context = movie.managedObjectContext else { return }
        context.perform {
            do {
                context.delete(movie)
                try CoreDataStack.shared.save(context: context)
            } catch {
                context.reset()
                print("Error deleting a movie: \(error)")
            }
        }
    }
}
