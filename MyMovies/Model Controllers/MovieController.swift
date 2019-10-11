//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData
import Firebase

class MovieController {
    
    
//MARK: - properties
    var searchedMovies: [MovieRepresentation] = []
    private let dataBaseUrl = URL(string: "https://mymovies-9f7f0.firebaseio.com/")!
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    
//MARK: - methods
    
    //create method
func createMovie(with title: String) {
        let movie = Movie(title: title, context: CoreDataStack.shared.mainContext)
        putMovieInDatabase(movie)
        CoreDataStack.shared.mainContext.saveChanges()
    }
    
    // update Method
    func updateHasBeenWatched(forMovie movie: Movie) {
        movie.hasWatched = !movie.hasWatched
        putMovieInDatabase(movie)
        
    }
    
    //delete Method
    func deleteMovie(_ movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        deleteMovieFromServer(movie: movie)
        CoreDataStack.shared.mainContext.saveChanges()
    }
    
}

// MARK: - extension for the json encoding method.
extension MovieController {
    
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

// MARK: - extension for the movie Database fetchRequest.
extension MovieController {
    
    func putMovieInDatabase(_ movie: Movie, completion: @escaping(Error?) -> Void = {_ in}) {
        
        let movieIdentifier = movie.identifier ?? UUID().uuidString
        let firebaseURL = dataBaseUrl.appendingPathComponent(movieIdentifier).appendingPathExtension("json")
           var request = URLRequest(url: firebaseURL)
         request.httpMethod = "PUT"
            
        do {
            request.httpBody = try JSONEncoder().encode(movie.movieRepresentation)
           } catch let error as NSError {
               print("error: encoding Movie: \(error)")
           }
       
        URLSession.shared.dataTask(with: request) { (_,_,error) in
            if let error = error as NSError? {
                print("error putting movie into database: \(error.localizedDescription)")
            }
            
            
        }.resume()
       }


    func deleteMovieFromServer(movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        
        guard let identifier = movie.identifier else {
            NSLog("movie identifier is nil")
            completion(NSError())
            return
        }
        let requestURL = dataBaseUrl.appendingPathComponent(identifier).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error deleting movie from server: \(error)")
                completion(error)
                return
            }

            completion(nil)
            }.resume()
    }
    
    func updateMovie(with movie: Movie, hasBeenWatched: Bool) {
        movie.hasWatched = !hasBeenWatched
        putMovieInDatabase(movie)
    }
    private func update(movie: Movie, with movieRep: MovieRepresentation) {
        movie.title = movieRep.title
        movie.identifier = movieRep.identifier
        movie.hasWatched = movieRep.hasWatched ?? false
    }
    
}
