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
    
    static let shared = MovieController()
    
    private let fireBaseURL = URL(string: "https://mymovies-ca563.firebaseio.com/")!
    typealias CompletionHandler = (Error?) -> Void
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
    
    init() {
        fetchEntriesFromServer()
    }
    
    func fetchEntriesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = fireBaseURL.appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            guard error == nil else {
                print("Error fetching Movies: \(error!)")
                completion(error)
                return
            }
            guard let data = data else {
                print("No data returned by data Movies")
                completion(NSError())
                return
            }
            
            var movieRepresentations: [MovieRepresentation] = []
            
            do {
                let decodeMovies = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
                movieRepresentations = Array(decodeMovies.values)
                
                //                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                
                try self.updateMovies(with: movieRepresentations)
                
                completion(nil)
            } catch {
                print("Error decoding Movie representations: \(error)")
                completion(error)
                return
            }
            
        }.resume()
    }
    
    
    func put(movie: Movie, completion: @escaping CompletionHandler = {_ in}) {
        
        let uuid = movie.identifier ?? UUID()
        let requestURL = fireBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard let representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            
            movie.identifier = uuid
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding task \(movie): \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil else {
                print("Error PUTing entry to server: \(error!)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func create(title: String) {
        
        let movie = Movie(title: title)
        put(movie: movie)
        do {
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
        } catch {
            print("error saving movie: \(error)")
        }
        
    }
    
    func update(movie: Movie, with representation: MovieRepresentation) {
        guard let hasWatched = representation.hasWatched else { return }
        
        movie.title = representation.title
        movie.hasWatched = hasWatched    
    }
    
    private func updateMovies(with representations: [MovieRepresentation]) throws {
        
        let moviesWithID = representations.filter { $0.identifier != nil }
        let identifiersToFetch = moviesWithID.compactMap { $0.identifier! }
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
        var moviesToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.perform {
            do {
                let exsistingMovies = try context.fetch(fetchRequest)
                for movie in exsistingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else {
                            let moc = CoreDataStack.shared.mainContext
                            moc.delete(movie)
                            continue
                    }

                    self.update(movie: movie, with: representation)
                    moviesToCreate.removeValue(forKey: id)
                }
                for representation in moviesToCreate.values {
                   let _ = Movie(movieRepresentation: representation, context: context)
                }
            } catch {
                print("Error fetching tasks for UUIDs: \(error)")
            }
        }
        
        do {
            try CoreDataStack.shared.save(context: context)
            
        } catch {
            print("error saving movie: \(error)")
        }
    }
    
    func toggle(movie: Movie) {
        do {
        movie.hasWatched.toggle()
        try CoreDataStack.shared.save()
        } catch {
            print("error toggle button hasWatched: \(error)")
        }
        put(movie: movie)
    }
    
    
    
    func delete(for movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        deleteEntryFromServer(movie)
        do{
            try CoreDataStack.shared.save()
            
        } catch {
            print("error saving movie: \(error)")
        }
    }
    
    func deleteEntryFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in}) {
        guard let identifier = movie.identifier else {
            completion(NSError())
            return
        }
        let requestURL = fireBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error deleting entry from server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
