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
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    typealias CompletionHandler = (Error?) -> Void
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    //
    private let fireBaseURL = URL(string: "https://movie-sprint-fca53.firebaseio.com/")!
    
//    init() {
//        fetchMyMoviesFromServer()
//    }
    //
    // MARK: - API Functions
    
    
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
    
    // MARK: - Core Data
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {

        let requestURL = fireBaseURL.appendingPathExtension("json")

        let request = URLRequest(url: requestURL)

        URLSession.shared.dataTask(with: request) { (data, _, error) in

            if let error = error {
                print("Error fetching movies: \(error)")
                completion(error)
                return
            }

            guard let data = data else {
                print("No data return from movie fetch data task")
                completion(error)
                return
            }

            let decoder = JSONDecoder()

            do {
                let decoded = try decoder.decode([String: MovieRepresentation].self, from: data).map({ $0.value })
                self.updateMovies(with: decoded)
            } catch {
                print("Error decoding representaions: \(error)")
            }
            completion(error)
        }.resume()
    }
    
    
    func put(movie: Movie, completion: @escaping () -> Void = { }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = fireBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        guard let representation = movie.movieRepresentation else {
            completion()
            return }
            
        let context = CoreDataStack.shared.mainContext
            
            do {
                try CoreDataStack.shared.save(context: context)
                request.httpBody = try JSONEncoder().encode(representation)
            } catch {
                print("Error encoding movie representation: \(error)")
                completion()
                return
            }
            
            URLSession.shared.dataTask(with: request) { _, _, error in
                
                if let error = error {
                    print("Error PUTting data: \(error)")
                    completion()
                    return
                }
                completion()
            }.resume()
        }
    
    
    func updateMovies(with representions: [MovieRepresentation]) {
        let moviesWithID = representions.filter { $0.identifier != nil }
        let identifiersToFetch = moviesWithID.compactMap { $0.identifier!}
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representions))
        
        var moviesToCreate = representationsByID
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        let fetchReqeust: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchReqeust.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        context.perform {
        do {
            let existingMovies = try context.fetch(fetchReqeust)
            for movie in existingMovies {
                guard let id = movie.identifier,
                    let representation = representationsByID[id] else { continue }
                
                movie.title = representation.title
                movie.hasWatched = representation.hasWatched!
                moviesToCreate.removeValue(forKey: id)
            }
            
            for representation in moviesToCreate.values {
                Movie(movieRepresentation: representation, context: context)
            }
            try CoreDataStack.shared.save(context: context)

        } catch {
            print("Eerror fetching movies w/ UUIDs: \(error)")
            }
        }
    
    }
    
    func deleteMovie(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let context = CoreDataStack.shared.mainContext
        
        do {
            context.delete(movie)
            try CoreDataStack.shared.save(context: context)
        } catch {
            context.reset()
            print("Error deleting object from managed object context: \(error)")
        }
        
        let requestURL = baseURL.appendingPathExtension(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(response!)
            completion(error)
        }.resume()
    }
    
    
    // MARK: - Updates in App


//    func create(title: String, hasWatched: Bool) {
//        let movie = Movie(title: title, hasWatched: hasWatched)
//    }
//
//    func update(movie: Movie) {
//        movie.hasWatched = true
//    }
//
//    func delete(movie: Movie) {
//        // finish after
//    }
    
    
    
    
    
    
    
    
    
    
}
