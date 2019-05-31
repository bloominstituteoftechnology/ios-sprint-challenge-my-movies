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
    private let firebaseBaseURL = URL(string: "https://coredata-283af.firebaseio.com/")!
    
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
    
    // MARK: - CRUD
    
    func put(movie: Movie, completion: @escaping ((Error?) -> Void) =  { _ in }) {
        guard let identifier = movie.identifier else {
            return print("No ID in PUT request")
        }
        
        let url = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        
        do {
            guard let movie = movie.movieRepresentation else {
                return completion(NSError())
            }
            
            urlRequest.httpBody = try JSONEncoder().encode(movie)
        } catch {
            NSLog("Error encoding entry: \(error.localizedDescription)")
            return completion(error)
        }
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTTING data to server: \(error.localizedDescription)")
                return completion(nil)
            }
            completion(nil)
            } .resume()
    }
    
    func create(title: String) {
        let moc = CoreDataStack.shared.mainContext

        moc.perform {
            let movie = Movie(title: title)
            self.put(movie: movie)
        }
    }
    
    func update(movie: Movie, representation: MovieRepresentation) {
        let moc = CoreDataStack.shared.mainContext

        moc.perform {
            movie.title = representation.title
            movie.identifier = representation.identifier
            movie.hasWatched = representation.hasWatched!
            self.put(movie: movie)
        }
    }
    
    func delete(movie: Movie) {
        let moc = CoreDataStack.shared.mainContext
        deleteMovieFromServer(movie: movie)

        moc.perform {
            do {
                moc.delete(movie)
                try CoreDataStack.shared.save(context: moc)
            } catch let deleteError {
                NSLog("Error deleting moc: \(deleteError)")
                return
            }
        }
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }){
        guard let identifier = movie.identifier else {return}
        
        let url = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                NSLog("Error sending deletion request to server: \(error.localizedDescription)")
                return completion(error)
            }
            completion(nil)
            }.resume()
    }
    
    
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void) {
        
        let url = firebaseBaseURL.appendingPathExtension("json")
        var urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                return completion(error)
            }
            guard let data = data else {
                return completion(NSError())
            }
            do {
                let movieData = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
                let myMovieRep = Array(movieData.values)
                
                for movieRep in myMovieRep {
                    self.update(movie: movieRep, representation: movieRep)
                }
                
            } catch {
                return completion(error)
            }}.resume()
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
