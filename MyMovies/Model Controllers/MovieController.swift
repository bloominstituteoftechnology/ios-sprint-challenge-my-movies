//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import CoreData

class MovieController {
    
    //MARK: Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    //MARK: MovieDB
    
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
        let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
        
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
    
    //MARK: Firebase
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    func put(movieRepresentation: MovieRepresentation, completion: @escaping (Error?) -> Void = {_ in}) {
        let baseURL = URL(string: "https://mymovies-497c3.firebaseio.com/")!
        
        guard let identifier = movieRepresentation.identifier else {
            NSLog("No identifier for movie.")
            completion(NSError())
            return
        }
        
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            NSLog("Error encoding movie representation: \(error)")
            completion(NSError())
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting movie: \(error)")
                completion(NSError())
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    func put(movie: Movie, completion: @escaping (Error?) -> Void = {_ in}) {
        guard let movieRepresentation = movie.representation else {
            NSLog("Movie representation is nil")
            completion(NSError())
            return
        }
        
        put(movieRepresentation: movieRepresentation, completion: completion)
    }
    
    //MARK: CoreData

    func addMovie(_ movieRepresentation: MovieRepresentation, context: NSManagedObjectContext) {
        guard let movie = Movie(movieRepresentation: movieRepresentation, context: context) else { return }
        CoreDataStack.shared.save(context: context)
        put(movie: movie)
    }
    
    func toggleWatched(movie: Movie, context: NSManagedObjectContext) {
        movie.hasWatched.toggle()
        CoreDataStack.shared.save(context: context)
        put(movie: movie)
    }

}
