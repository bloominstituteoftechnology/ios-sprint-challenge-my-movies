//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class MovieController {
    
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
    
    // MARK: - Local Persistence
    
    func saveToPersistentStore() {
        let moc = CoreDataStack.shared.mainContext
        do {
            try moc.save()
        } catch {
            moc.reset()
            NSLog("Error saving to persistent store:\(error)")
        }
    }
    
    // MARK: - Remote Persistence
    
    private func put(movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        let url = firebaseURL.appendingPathComponent(movie.identifier!.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        do {
            let data = try JSONEncoder().encode(movie)
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
