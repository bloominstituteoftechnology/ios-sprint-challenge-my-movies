//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class MovieController {
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let fireBaseURL = URL(string: "https://lambdasprintchallenge.firebaseio.com/")!
    private let fireBasePathExtension: String = "json"
    
    // MARK: -CRUD Methods
    
    private func createMovie(with hasWatched: Bool,
                             identifier: UUID,
                             title: String) {
        let movie = Movie(hasWatched: hasWatched,
                          identifier: identifier,
                          title: title)
        
        put(movie: movie)
        
        CoreDataStack.shared.save()
    }
    
    func update(movie: Movie,
                hasWatched: Bool,
                identifier: UUID,
                title: String) {
        movie.hasWatched = hasWatched
        movie.identifier = identifier
        movie.title = title
        
        put(movie: movie)
        
        CoreDataStack.shared.save()
    }
    
    func delete(movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        deleteFromFireBase(movie: movie)
        CoreDataStack.shared.save()
    }
        
    // MARK: API Methods
    
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
                let movieRepresentations = try JSONDecoder().decode(MovieListRepresentations.self, from: data).results
                self.searchedMovies = movieRepresentations
                completion(nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    func deleteFromFireBase(movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        guard let identifier = movie.identifier else {
            NSLog("Movie identifier is nil")
            completion(NSError())
            return
        }
        
        let requestURL = fireBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension(fireBasePathExtension)
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethods.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error deleting movie from server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    

    // MARK: - CoreData Methods
    
    func put(movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        
        let identifier = movie.identifier ?? UUID()
        let requestURL = fireBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension(fireBasePathExtension)
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethods.put.rawValue
        
        do{
            request.httpBody = try JSONEncoder().encode(movie.entryRepresentation)
        } catch {
            NSLog("Error encoding Movie: \(error)")
            completion(error)
            return
        }
        
    }
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
