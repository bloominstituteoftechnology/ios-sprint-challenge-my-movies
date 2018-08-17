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
    
    init() {
        fetchMoviesFromServer()
    }
    
    // MARK: - CRUD
    
    func createMovie(withTitle title: String) {
        let movie = Movie(title: title)
        saveToPersistentStore()
        put(movie: movie)
    }
    
    func updateToggle(for movie: Movie) {
        movie.hasWatched = !movie.hasWatched
        saveToPersistentStore()
        put(movie: movie)
    }
    
    func delete(movie: Movie) {
        let moc = CoreDataStack.shared.mainContext
        deleteMovieFromServer(movie: movie)
        moc.delete(movie)
        saveToPersistentStore()
    }
    
    // MARK: - Local Persistent Store
    
    func saveToPersistentStore() {
        let moc = CoreDataStack.shared.mainContext
        do {
            try moc.save()
        } catch {
            moc.reset()
            NSLog("Error saving to persistent store:\(error)")
        }
    }
    
    private func fetchSingleMovieFromPersistentStore(withID identifier: UUID) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier as NSUUID)
        let moc = CoreDataStack.shared.mainContext
        do {
            let movies = try moc.fetch(fetchRequest)
            return movies.first
        } catch {
            NSLog("Error fetching single Movie: \(error).")
            return nil
        }
    }
    
    // MARK: - Remote Persistence
    
    private func put(movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        // let uuid = movie.identifier ?? UUID()
        let url = firebaseURL.appendingPathComponent((movie.identifier?.uuidString)!).appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        do {
            guard var representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            // representation.identifier = uuid
            // movie.identifier = uuid
            
            let data = try JSONEncoder().encode(representation)
            request.httpBody = data
        } catch {
            NSLog("Error PUTting data: \(error)")
        }
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error using URLSession with PUT:\(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    private func deleteMovieFromServer(movie: Movie, completion: @escaping (Error?) -> Void = { _ in } ) {
        let url = firebaseURL.appendingPathComponent(movie.identifier!.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        do {
            let data = try JSONEncoder().encode(movie)
            request.httpBody = data
        } catch {
            NSLog("Error DELETEing data: \(error)")
        }
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error using URLSession with DELETE:\(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    // MARK: - Synchronizing CoreData with Remote storage
    
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        let url = firebaseURL.appendingPathExtension("json")
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error with URLSession re: fetching movies: \(error).")
                completion(error)
            }
            guard let data = data else { return }
            
            do {
                let decodedData = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                try self.updateMovies(with: decodedData)
                completion(nil)
            } catch {
                NSLog("Error decoding Movies data from server: \(error)")
            }
        }.resume()
    }
    
    private func updateMovies(with representations: [MovieRepresentation]) throws {
        var error: Error?
        let moc = CoreDataStack.shared.mainContext // until background conconcurrency is implemented
        for movieRep in representations {
            let movie = self.fetchSingleMovieFromPersistentStore(withID: movieRep.identifier!)
            if movie != nil {
                if movie! == movieRep {
                    // do nothing
                } else if movie! != movieRep {
                    self.updateMovieRepresentation(with: movie!, movieRepresentation: movieRep)
                }
            } else {
                let _ = Movie(movieRepresentation: movieRep)
            }
        }
        do {
            try moc.save()
        } catch let saveError {
            moc.reset()
            error = saveError
        }
        if let error = error { throw error }
    }
    
    private func updateMovieRepresentation(with movie: Movie, movieRepresentation: MovieRepresentation) {
        movie.title = movieRepresentation.title
        movie.identifier = movieRepresentation.identifier
        movie.hasWatched = movieRepresentation.hasWatched!
    }
    
    
    // MARK: - API and Networking
    
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
    
    let firebaseURL = URL(string: "https://mymovies-27a55.firebaseio.com/")!
    
    var searchedMovies: [MovieRepresentation] = []
}
