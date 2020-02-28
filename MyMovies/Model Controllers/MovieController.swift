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
    case delete = "DELETE"
}

class MovieController {
    
    typealias CompletionHandler = (Error?) -> Void
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let serverBaseURL = URL(string: "https://movies-a45a2.firebaseio.com/")!
    
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
    
    var searchedMovies: [MovieRepresentation] = []
    
    func saveMovie(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let movie = Movie(movieRepresentation: movieRepresentation) else { return }
        do {
            try context.save()
            saveMovieToServer(movie: movie)
        } catch {
            NSLog("Error saving movie: \(error)")
        }
    }
    
    func saveMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = serverBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        do {
            guard let representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            
            movie.identifier = uuid
            
            try CoreDataStack.shared.save()
            let json = try JSONEncoder().encode(representation)
            
            request.httpBody = json

        } catch {
            NSLog("Error decoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Network error PUTting data to server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            
        }.resume()
    }
    
    func deleteMovie(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let movieRepresentation = movie.movieRepresentation else { return }
        deleteMovieFromServer(movie: movieRepresentation)
        do {
            context.delete(movie)
            try context.save()
            
        } catch {
            context.reset()
            NSLog("Error saving movie: \(error)")
        }
    }
    
    func deleteMovieFromServer(movie: MovieRepresentation, completion: @escaping CompletionHandler = {_ in }) {
        guard let id = movie.identifier else {
            NSLog("Movie to delete has no identifier")
            completion(NSError())
            return
        }
        
        let requestURL = serverBaseURL.appendingPathExtension(id.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Error Deleting movie from server")
                completion(error)
                return
            }
            
            completion(nil)
            
        }.resume()
        
    }
    
}
