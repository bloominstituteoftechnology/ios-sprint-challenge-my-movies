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
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    let firebaseURL = URL(string: "https://mymovies-2d3de.firebaseio.com/")!
    
    
    // MARK: - Methods
    
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void = { _ in } ) {
        let requestURL = firebaseURL.appendingPathExtension(".json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error fetching movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                print("No data returned")
                completion(error)
                return
            }
            
            do {
                let movieRepresentation = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                
                let moc = CoreDataStack.shared.container.newBackgroundContext()
                
                try self.updateMovies(with: movieRepresentation, context: moc)
                completion(nil)
            } catch {
                print("Error decoding movie representation")
                completion(error)
                return
            }
        }
    }
    
    private func updateMovies(with representations: [MovieRepresentation], context: NSManagedObjectContext) throws {
        var error: Error? = nil
        
        context.performAndWait {
            
            for movieRepresentation in representations {
                guard let movieID = movieRepresentation.identifier else {continue}
                if let movie = self.movie(for: movieID, in: context) {
                    self.update(movie: movie, with: movieRepresentation)
                } else {
                    let _ = Movie(movieRepresentation: movieRepresentation, context: context)   //
                }
            }
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        if let error = error { throw error }
        
        try CoreDataStack.shared.save(context: context)
    }
    
    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched!
        
    }

    func movie(for movieID: UUID, in context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", movieID as NSUUID)
        
        var result: Movie? = nil
        
        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching task with uuid: \(error)")
            }
        }
        return result
    }
    
    func put(movie: Movie, completion: @escaping (Error?) -> Void = {_ in }) {
        let identifier = movie.identifier ?? UUID()
//        movie.identifier = identifier
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard var movieRepresentation = movie.movieRepresentation else {
            print("Movie representation is nil")
            completion(NSError())
            return
        }
        
        do {
            movieRepresentation.identifier = identifier
            try saveToPersistentStore()
            
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            print("Error encoding movie representation: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("Error PUTing movie: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func saveToPersistentStore() throws {
        try CoreDataStack.shared.mainContext.save()
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping (Error?) -> Void) {
        guard let uuid = movie.identifier else {
            completion(nil)
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            print("Deleted task with UUID: \(uuid.uuidString)")
            completion(error)
        }.resume()
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
