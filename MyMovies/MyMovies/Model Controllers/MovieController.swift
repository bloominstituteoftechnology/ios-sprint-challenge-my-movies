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
    
    init() {
        fetchMoviesFromServer()
    }
    
    // MARK: - Properties
    var searchedMovies: [MovieRepresentation] = []
    
    // MARK: - MovieSearch
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
    
    // MARK: - CRUD CoreData
    
    let firebaseURL = URL(string: "https://journal-9006c.firebaseio.com/")!
    
    func createMovie(title: String, hasWatched: Bool) {
        let movie = Movie(title: title, hasWatched: hasWatched)
        
        put(movie: movie)
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving context: \(error)")
        }
    }
    
    func updateMovie(movie: Movie, hasWatched: Bool) {
        movie.hasWatched = hasWatched
        
        put(movie: movie)
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving context: \(error)")
        }
    }
    
    func deleteMovie(movie: Movie) {
        let moc = CoreDataStack.shared.mainContext
        
        moc.delete(movie)
        deleteMovieFromServer(movie: movie)
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving context: \(error)")
        }
    }
    
    func fetchMoviesFromServer(completion: @escaping () -> Void = { }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                NSLog("Bad response fetching movies, response code: \(response.statusCode)")
                completion()
                return
            }
            
            if let error = error {
                NSLog("Error fetching movies from server: \(error)")
                completion()
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from fetching movies from server")
                completion()
                return
            }
            
            do {
                let decodedJSON = try JSONDecoder().decode([String : MovieRepresentation].self, from: data)
                let movieRepresentations = Array(decodedJSON.values)
                let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
                
                self.updateMovies(with: movieRepresentations, context: backgroundContext)
                try CoreDataStack.shared.save(context: backgroundContext)
            } catch {
                NSLog("Error decoding movie representations \(error)")
                completion()
                return
            }
            }.resume()
    }
    
    func put(movie: Movie, completion: @escaping () -> Void = { }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        do {
            request.httpBody = try JSONEncoder().encode(movie.movieRepresentation)
        } catch {
            NSLog("Error encoding movie \(movie): \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting movie to server: \(error)")
                completion()
                return
            }
            
            completion()
        }.resume()
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error deleting movie from server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            }.resume()
    }
    
    private func fetchSingleMovieFromPersistentStore(identifier: UUID, context: NSManagedObjectContext) -> Movie? {
//        guard let uuid = UUID(uuidString: identifier) else { return nil }
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier as NSUUID)
        
        var movie: Movie? = nil
        
        context.performAndWait {
            do {
                movie = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching movie with uuid \(identifier): \(error)")
            }
        }
        
        return movie
    }
    
    private func update(movie: Movie, representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched ?? false
        movie.identifier = representation.identifier
    }
    
    private func updateMovies(with representations: [MovieRepresentation], context: NSManagedObjectContext) {
        context.performAndWait {
            for representation in representations {
                guard let identifier = representation.identifier else { return }
                let movie = fetchSingleMovieFromPersistentStore(identifier: identifier, context: context)
                
                if let movie = movie {
                    if movie != representation {
                        update(movie: movie, representation: representation)
                    }
                } else {
                    Movie(movieRepresentation: representation)
                }
            }
        }
    }
    
}
