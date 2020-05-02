//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum NetworkError: Error {
    case noIdentifier
    case otherError
    case noData
    case noDecode
    case noEncode
    case noRep
}

class MovieController {
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
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
    var movieRepresentation: MovieRepresentation?
    let moc = CoreDataStack.shared.mainContext
    
    // Core data
    var firebaseURL = URL(string: "https://my-movies-2e66b.firebaseio.com/")
    
    // Send movies to server
    func putMoviesToServer(movie: Movie, completion: @escaping CompletionHandler = {_ in}) {
        guard let identifier = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"

        do {
            guard let movieRepresentation = movie.movieRepresentation else {
                completion(.failure(.noRep))
                return
            }
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            NSLog("Error encoding movie \(movie): \(error)")
            completion(.failure(.noEncode))
            return
        }
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting movie to server: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.otherError))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(true))
            }
        }.resume()
    }
    
//    // Get movies from server
//    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
//
//        let requestURL = baseURL.appendingPathExtension("json")
//
//        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
//
//            if let error = error {
//                NSLog("Error fetching tasks: \(error)")
//                DispatchQueue.main.async {
//                    completion(.failure(.otherError))
//                }
//                return
//            }
//
//            guard let data = data else {
//                NSLog("Error: No data returned from data task")
//                DispatchQueue.main.async {
//                    completion(.failure(.noData))
//                }
//                return
//            }
//            do {
//                let movieRepresentation = try JSONDecoder().decode( MovieRepresentation.self, from: data).results
//                self.updateMovies(with: movieRepresentation)
//                DispatchQueue.main.async {
//                    completion(.success(true))
//                }
//            } catch {
//                NSLog("Error decoding movie representations: \(error)")
//                DispatchQueue.main.async {
//                    completion(.failure(.noDecode))
//                }
//            }
//        }.resume()
//    }
    
    func updateMovies(with representations: [MovieRepresentation]) throws {
        
        let moviesByID = representations.filter { $0.identifier != nil}
        let identifiersToFetch = moviesByID.compactMap { $0.identifier }
        let representationsByID = Dictionary(uniqueKeysWithValues:
            zip(identifiersToFetch, moviesByID)
        )
        
        // Make a copy of the representationsByID for later use
        var moviesToCreate = representationsByID
        
        // Ask Core Data to find any tasks with these identifiers
        let predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = predicate
        
        // Create a new backround context. The thread that this context is created on is completely random; you have no control over it
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        // I want to make sure I'm using this context on the right thread, so I will call .perform
        context.performAndWait {
            do {
                // This will only fetch the movies that match the criteria in our predicate
                let existingMovies = try context.fetch(fetchRequest)
                
                // Let's update the movies that already exist in Core Data
                for movie in existingMovies {
                    
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else { continue }
                    
                    updateMovie(movie: movie, with: representation)
                    
                    // If we updated the movie, that means we don't need to make a copy of it. It already exists in Core Data, so remove it from the movies we still need to create
                    moviesToCreate.removeValue(forKey: id)
                }
                
                // Add the movies that don't exist
                for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
                
            } catch {
                NSLog("Error fetching tasks for UUIDs: \(error)")
            }
        }
        
        // This will save the correct context (backround context)
        try CoreDataStack.shared.save(context: context)
    }
    
    func saveToPersistentStore() {
        do {
            try moc.save()
        } catch {
            moc.reset()
            print("Error saving to persistent store: \(error)")
        }
    }

    // Delete movies from server
    func deleteMoviesFromServer(_ movie: Movie, completion: @escaping CompletionHandler = {_ in}) {
        
        guard let identifier = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                NSLog("Error: Status code isn't the expected 200. Instead it's \(response.statusCode)")
            }
            if let error = error {
                NSLog("Error deleting task for id \(identifier.uuidString): \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.otherError))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(true))
            }
        }
    }
    
    func addMovie(title: String, identifier: UUID, hasWatched: Bool, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        let newMovie = Movie(identifier: identifier, title: title, hasWatched: hasWatched, context: context)
        context.insert(newMovie)
        putMoviesToServer(movie: newMovie)
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error add movie: \(error)")
        }
    }
    
    func deleteMovie(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.delete(movie)
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error deleting movie: \(error)")
        }
    }
    
    func updateMovie(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched ?? false
    }

}
    
    
    

