//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String{
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

class MovieController {
    
    typealias CompletionHandler = (Error?) -> Void
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    init() {
//        searchForMovie()
    }
    
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
        
        func sendMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
            let uuid = movie.identifier ?? UUID()
            let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
            var request = URLRequest(url: requestURL)
            request.httpMethod = "PUT"
            do {
                guard var representation = movie.movieRepresentation else {
                    completion(NSError())
                    return
                }
                representation.identifier
                movie.identifier = uuid
                try CoreDataStack.shared.save()
                request.httpBody = try JSONEncoder().encode(representation)
            } catch {
                print("Error encoding task: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    print(" error putting task to server: \(error)")
                    DispatchQueue.main.async {
                        completion(error)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(nil)
                }
                
            }.resume()
        }
        
        func deleteFromServer(_ movie: Movie, completion: @escaping()-> Void = {}) {
            
            guard let identifier = movie.identifier else {
                completion()
                return
            }
            
            let requestURL = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
            
            var request = URLRequest(url: requestURL)
            request.httpMethod = HTTPMethod.delete.rawValue
            
            URLSession.shared.dataTask(with: request) { data, _, error in
                
                if let error = error {
                    NSLog("Error deleting: \(error)")
                    completion()
                    return
                }
                completion()
            }.resume()
        }
        
        func createMovie(withTitle: String, hasWatched: Bool, identifier: UUID) {
            let movie = Movie(hasWatched: Bool, identifier: UUID, title: String)
            
            sendMovieToServer(movie: movie)
        }
        
        func delete(movie: Movie) {
            deleteFromServer(movie)
            CoreDataStack.shared.mainContext.delete(movie)
            CoreDataStack.shared.save()
            }
        
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
