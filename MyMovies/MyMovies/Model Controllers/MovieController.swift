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
    typealias ComplitionHandler = (Error?) -> Void
    
    // MARK: - BaseURL & APIkey
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let baseURL2 = URL(string: "https://mymovie-ilqarilyasov.firebaseio.com/")!
    
    // MARK: - GET searchTerm
    
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


extension MovieController {
    
    // CRUD functions
    
    func createMovie(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let title = movie.title else { return }
        let movie = Movie(title: title)
        
        do {
           try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error createing a movie: \(error)")
        }
        
        putMovieToServer(movie: movie)
        
    }
    
    func updateStatus(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        movie.hasWatched = !movie.hasWatched
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error updating movie watch status: \(error)")
        }
        
        putMovieToServer(movie: movie)
    }
    
    func deleteMovie(movie: Movie) {
        
        deleteMovieFromServer(movie: movie)
        
        let moc = CoreDataStack.shared.mainContext
        do {
            moc.delete(movie)
            try moc.save()
        } catch {
            moc.reset()
            NSLog("Error deleting movie: \(error)")
        }
    }
    
    // MARK: - Serverside functions
    
    func putMovieToServer(movie: Movie, completion: @escaping ComplitionHandler = { _ in }) {
        guard let id = movie.identifier else { completion(NSError()); return }
        
        let url = baseURL2.appendingPathComponent(id).appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put.rawValue
        
        do {
            let movieData = try JSONEncoder().encode(movie)
            request.httpBody = movieData
            completion(nil)
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error puttind movie to the server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping ComplitionHandler = { _ in }){
        guard let id = movie.identifier else {completion(NSError()); return }
        
        let url = baseURL2.appendingPathComponent(id).appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting data: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
}
