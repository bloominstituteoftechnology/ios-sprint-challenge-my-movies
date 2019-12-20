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
    
    static let sharedInstance = MovieController()
    
    private let firebaseURL = URL(string: "https://ios12-movies.firebaseio.com/")!
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
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
    
    
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        let requestURL = firebaseURL.appendingPathExtension("json")

        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching movies: \(error)")
                DispatchQueue.main.async {
                completion(error)
                }
                return
            }

            guard let data = data else {
                print("No data returned in fetch")
                DispatchQueue.main.async {
                completion(NSError())
                }
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                try self.updateMovie(with: movieRepresentations)
                DispatchQueue.main.async {
                completion(nil)
                }
            } catch {
                print("Error decoding movie representation: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    func put(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"

        do {
            guard var representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            representation.identifier = uuid
            movie.identifier = uuid
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding movie: \(error)")
            completion(error)
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error putting movie to server \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }

        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response {
                print(response)
            }
            if let error = error {
                print("Error deleting entry to server \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            completion(nil)
        }.resume()
    }

    func updateMovie(with representation: [MovieRepresentation]) throws {
        let entriesWithId = representation.filter { $0.identifier != nil }
        let identifiersToFetch = entriesWithId.compactMap { $0.identifier! }
        let representationByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, entriesWithId))

        var entriesToCreate = representationByID

        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)

        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            do {
                let existingMovies = try context.fetch(fetchRequest)

                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationByID[id] else { continue }

                    self.update(movie: movie, with: representation)
                    entriesToCreate.removeValue(forKey: id)
                }

                for representation in entriesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
            } catch {
                print("Error fetching entries for UUIDs: \(error)")
            }
        }

        try CoreDataStack.shared.save(context: context)
    }

    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched ?? false
    }
    
    func createSavedMovie(title: String) {
        let movie = Movie(title: title)
        put(movie: movie)
        do {
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
        } catch {
            print("Error saving object \(error)")
        }
    }

    func hasWatchedMovie(for movie: Movie) {
        movie.hasWatched.toggle()
        put(movie: movie)
        do {
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
        } catch {
            print("Error saving object \(error)")
        }
    }

    func delete(for movie: Movie) {
        deleteMovieFromServer(movie)
        let context = CoreDataStack.shared.mainContext
        do {
            context.delete(movie)
            try CoreDataStack.shared.save(context: context)
        } catch {
            context.reset()
            print("Error deleting object from managed object context: \(error)")
        }
    }

    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
