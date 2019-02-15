//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case put = "PUT"
    case delete = "DELETE"
}

class MovieController {
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://mosesmymovies.firebaseio.com/")!
    
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
    
    func put(_ movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        
        let identifier = movie.identifier ?? UUID().uuidString
        
        let url = firebaseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.put.rawValue
        
        let jsonEncoder = JSONEncoder()
        
        do {
            
            let movieData = try jsonEncoder.encode(movie)
            urlRequest.httpBody = movieData
        } catch {
            NSLog("Error encoding entry: \(error)")
            completion(error)
        }
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                NSLog("Error putting entry to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }
        dataTask.resume()
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        let identifier = movie.identifier ?? UUID().uuidString
        
        let url = firebaseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.delete.rawValue
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                NSLog("Error putting entry to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }
        dataTask.resume()
    }
    
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        
        let url = firebaseURL.appendingPathExtension("json")
        
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching entry: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task ")
                completion(NSError())
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                
                let movieRepresentations = try jsonDecoder.decode([String : MovieRepresentation].self, from: data).map( { $0.value } )
                
                // iterate through movies
                
                completion(nil)
            } catch {
                NSLog("Error decoding Entry Representation: \(error)")
                completion(error)
            }
        }
        dataTask.resume()
    }
    
    func saveToPersistentStore() {
        do {
            try CoreDataStack.shared.save()
        } catch {
            CoreDataStack.shared.mainContext.reset()
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    func create(title: String) {
        let movie = Movie(title: title)
        
        put(movie)
        saveToPersistentStore()
    }
    
    func update(movie: Movie) {
    
        movie.hasWatched.toggle()
        
        put(movie)
        saveToPersistentStore()
    }
    
    func updateFromMovieRep(movie: Movie, movieRepresentation: MovieRepresentation) {
        
        movie.title = movieRepresentation.title
        movie.identifier = movieRepresentation.identifier
        movie.hasWatched = movieRepresentation.hasWatched ?? false
    }
    
    func delete(movie: Movie) {
        
        deleteMovieFromServer(movie)
        CoreDataStack.shared.mainContext.delete(movie)
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
