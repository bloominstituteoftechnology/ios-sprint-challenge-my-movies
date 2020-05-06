//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

enum NetworkError: Error {
    case noIdentifier
    case otherError
    case noData
    case noDecode
    case noEncode
    case noRep
}

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

import Foundation
import CoreData

class MovieController {
    
    static let sharedMovieController = MovieController()
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseBaseURL = URL(string: "https://mymovies-1974f.firebaseio.com/")!
    
    var searchedMovies: [MovieRepresentation] = []
    
    init() {
        fetchMoviesFromFirebase()
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
    
    func togglehasBeenWatched(movie: Movie) {
        movie.hasWatched.toggle()
        
        try? CoreDataStack.shared.saveManagedObjectContext()
        putMyMovies(movie: movie)
    }
    
    func saveMyMovieList(with movieRepresentation: MovieRepresentation) {
        guard let movie = Movie(movieRepresentation: movieRepresentation) else { return }
        
        do {
            try CoreDataStack.shared.saveManagedObjectContext()
            putMyMovies(movie: movie)
        } catch {
            NSLog("Error saving Movie from MovieRepresentation: \(error)")
        }
    }
    
    func movie(forUUID uuid: UUID, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        var result: Movie? = nil
        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching moive with uuid \(uuid): \(error)")
            }
        }
        return result
    }
    
    func updateMovieRepresentations(with movieRepresentations: [MovieRepresentation], context: NSManagedObjectContext) throws {
        var error: Error?
        context.performAndWait {
            for repsOfMovies in movieRepresentations {
                guard let uuid = repsOfMovies.identifier else { continue }
                if let movie = self.movie(forUUID: uuid, context: context) {
                    self.updateMovieCell(movie: movie, rep: repsOfMovies)
                } else {
                    let _ = Movie(movieRepresentation: repsOfMovies, context: context)
                }
            }
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        if let error = error { throw error }
    }
    
    func updateMovieCell(movie: Movie, rep: MovieRepresentation) {
        movie.title = rep.title
        movie.identifier = rep.identifier
        
        guard let hasWatched = rep.hasWatched else { return }
        movie.hasWatched = hasWatched
    }
    
    func putMyMovies(movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in}) {
        guard let identifier = movie.identifier,
            let movieRep = movie.movieRepresentation else {
                completion(NSError())
                return
        }
        let requestURL = firebaseBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        do {
            request.httpBody = try JSONEncoder().encode(movieRep)
        } catch {
            NSLog("Unable to encode movie representation: \(error)")
        }
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting movie to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func delete(movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        deleteMoviesFromFirebase(movie: movie)
        try? CoreDataStack.shared.saveManagedObjectContext()
    }
    
    func deleteMoviesFromFirebase(movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        guard let identifier = movie.identifier else {
            completion(NSError())
            return
        }
        let requestURL = firebaseBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
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
    
    func fetchMoviesFromFirebase(completion: @escaping ((Error?) -> Void) = { _ in }) {
        let requestURL = firebaseBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting movie to server: \(error)")
                completion(error)
                return
            }
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            do {
                let movieRepresentations = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({$0.value})
                let moc = CoreDataStack.shared.container.newBackgroundContext()
                try self.updateMovieRepresentations(with: movieRepresentations, context: moc)
                completion(nil)
            } catch {
                NSLog("Error decoding movie representations: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
}
