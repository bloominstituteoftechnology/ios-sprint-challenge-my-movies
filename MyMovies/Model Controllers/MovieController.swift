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
    
    typealias completionHandler = (Error?) -> Void
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let serverBaseURL = URL(string: "https://mymovies-8d6be.firebaseio.com/")!
    
    
    init() {
        fetchMoviesFromServer()
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
    
    func fetchMoviesFromServer(completion: @escaping completionHandler = { _ in }) {
        let requestURL = serverBaseURL.appendingPathComponent("Movie").appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            //if you want it to not to continue. if let, else continues in the code.
            guard error == nil else {
                print("Error fetching tasks: \(error!)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            guard let data = data else {
                print("No data returned by data task")
                DispatchQueue.main.async {
                    completion(NSError())
                }
                
                return
            }
            
            do {
                //we want the values of the dictionary
                
                let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                // Update tasks
                try self.updateMovies(with: movieRepresentations)
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                print("Error decoding task representations: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }.resume()
    }
    
    func updateMovies(with representations: [MovieRepresentation]) throws {
        let moviesWithID = representations.filter { $0.identifier != nil }
        //array of UUIDs. Removes any value that is nil
        let identifiersToFetch = moviesWithID.compactMap { $0.identifier }
        //creates a dictionary where key is UUID and the value is the task object
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
        var moviesToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.perform {
            do {
                let allMovies = try context.fetch(Movie.fetchRequest()) as? [Movie]
                let moviesToDelete = allMovies!.filter { !identifiersToFetch.contains($0.identifier!) }
                
                for movie in moviesToDelete {
                    context.delete(movie)
                }
                
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
                print("Error fetching task for UUIDs: \(error)")
                
            }
        }
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            print("Error saving to database")
        }
    }
    
    func sendMovieToServer(movie: Movie, completion: @escaping completionHandler = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        
        let requestURL = serverBaseURL.appendingPathComponent("Movie").appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            representation.identifier = uuid
            movie.identifier = uuid
            //update the main context bc we are on theUI
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding task \(movie): \(error)")
            completion(error)
            return
        }
        //background thread
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard error == nil else {
                print("Error PUTting task to server: \(error!)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
        
    }
    
    
    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title =  representation.title
        movie.hasWatched = representation.hasWatched ?? false
        movie.identifier = representation.identifier
    }
    // MARK: -  CRUD
    
    func createMovie(title: String, identifier: UUID, hasWatched: Bool) {
        let movie = Movie(title: title, identifier: identifier, hasWatched: hasWatched)
        sendMovieToServer(movie: movie)
    }
    
    func createMovie(from movieRepresentation: MovieRepresentation) {
        let title = movieRepresentation.title
        let identifier = movieRepresentation.identifier ?? UUID()
        let hasWatched = movieRepresentation.hasWatched ?? false
        createMovie(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping completionHandler = { _ in }) {
        
        CoreDataStack.shared.mainContext.perform {
            guard let uuid = movie.identifier else {
                completion(NSError())
                return
            }
            
            let requestURL = self.serverBaseURL.appendingPathComponent("Movie").appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
            var request = URLRequest(url: requestURL)
            request.httpMethod = "DELETE"
            
            URLSession.shared.dataTask(with: request) { (_, _, error) in
                guard error == nil else {
                    print("Error deleting task: \(error!)")
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
    }
    
    func toggleHasWatched(for movie: Movie) {
        movie.hasWatched.toggle()
        sendMovieToServer(movie: movie)
        
    }
    
}
