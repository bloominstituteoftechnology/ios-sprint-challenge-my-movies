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
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}

class MovieController {
    
    typealias CompletionHandler = (Error?) -> Void
    
    init() {
        fetchMoviesFromServer()
    }
    
    func saveToPersistentStore() {
          
          do {
              try CoreDataStack.shared.mainContext.save() // has to see with books array.
              
          } catch {
              NSLog("error saving managed obejct context: \(error)")
          }
      }
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let myBaseURL = URL(string: "https://mymovies-d9b8a.firebaseio.com/")!
    
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
    
//    Core Data CRUD
    func createMovie(title: String, hasWatched: Bool, identifier: UUID) {
        let movie = Movie(title: title, identifier: identifier, hasWatched: hasWatched)
         putMovie(movie)
    }
      func updateMovie(for movie: Movie) {
        movie.hasWatched.toggle()
         putMovie(movie)
    }
    func createMovie(movieRepresentation: MovieRepresentation) {
        let title = movieRepresentation.title
        let identifier = movieRepresentation.identifier ?? UUID()
        let hasWatched = movieRepresentation.hasWatched ?? false
        createMovie(title: title, hasWatched: hasWatched, identifier: identifier)
    }
    func delete(movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
         putMovie(movie)
        saveToPersistentStore()
        
    }
    
//    CRUD From Server
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in  }) {
        let requestURL = myBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            guard error == nil else {
                print("Error fetching movies from server: \(error!)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            guard let data = data else {
                print("No data returned by data task.")
                DispatchQueue.main.async {
                    completion(NSError())
                }
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                try self.updateMovies(with: movieRepresentations)
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                print("Error decoding movie representations: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }.resume()
    }
    
    
     func deleteMovieFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        let httpMethod = HTTPMethod.self
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = httpMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            completion(error)
        }.resume()
    }
    
    private func putMovie(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let movieContext = movie.managedObjectContext else { return }
          let uuid = movie.identifier ?? UUID()
        let requestURL = myBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
                
        movieContext.performAndWait {
            do {
                guard let representation = movie.movieRepresentation else {
                    completion(NSError())
                    return
                }
                try CoreDataStack.shared.save()
                request.httpBody = try JSONEncoder().encode(representation)
            } catch {
                print("Error encoding movie: \(error)")
                completion(error)
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard error == nil else {
                print("Error PUTting movie to server: \(error!)")
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

    
    
    private func updateMovies(with representations: [MovieRepresentation]) throws {
        let representationsWithID = representations.filter { $0.identifier != nil }
        let identifiersToFetch = representationsWithID.compactMap { $0.identifier! }
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representationsWithID))
        var moviesToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.perform {
            do {
                // Delete existing movies not found in server database
                let allExistingMovies = try context.fetch(Movie.fetchRequest()) as? [Movie]
                let moviesToDelete = allExistingMovies!.filter { !identifiersToFetch.contains($0.identifier!) }
                
                for movie in moviesToDelete {
                    context.delete(movie)
                }
                
                // Update existing movies found in server database
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else { continue }
                    
                    self.update(movie: movie, with: representation)
                    moviesToCreate.removeValue(forKey: id)
                }
                
                // Create new movies found in server database
                for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
            } catch {
                print("Error fetching movies for UUIDs: \(error)")
            }
        }
        
        try CoreDataStack.shared.save(context: context)
    }
    private func update(movie: Movie, with movieRepresentation: MovieRepresentation) {
           movie.title = movieRepresentation.title
           movie.hasWatched = movieRepresentation.hasWatched ?? false
           movie.identifier = movieRepresentation.identifier
       }
    
    
}
