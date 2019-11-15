//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class MovieController {
    
    // MARK: - Properties
    
    static let shared = MovieController()
    
    var searchedMovies: [MovieRepresentation] = []
    private let firebaseController = FirebaseController()
    
    // MARK: - TMDB API
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        let queryParameters = [
            "query": searchTerm,
            "api_key": apiKey
        ]
        components?.queryItems = queryParameters.map({
            URLQueryItem(name: $0.key, value: $0.value)
        })
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
    
    func addMovieFromTMDB(movieRep: MovieRepresentation) {
        // TODO: prevent user from adding movie twice
        guard let movie = Movie(
            representation: movieRep,
            context: CoreDataStack.shared.mainContext
            ) else {
                print("Failed to add movie from TMDB; CoreData object initialization failed.")
                return
        }
        firebaseController.sendToServer(movie: movie)
    }
    
    func delete(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            print("Movie has no identifier!")
            completion(NSError())
            return
        }
        
        let context = CoreDataStack.shared.mainContext
        
        do {
            context.delete(movie)
            try CoreDataStack.shared.save()
        } catch {
            context.reset()
            print("Error deleting object from managed object context: \(error)")
        }
        
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            completion(error)
        }.resume()
    }
}
