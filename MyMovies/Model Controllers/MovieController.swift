//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod : String {
    case PUT
    case GET
    case POST
    case DELETE
}
class MovieController {
    
    private let firebaseBaseURL =  URL(string: "https://movie-64f5c.firebaseio.com/")!
    typealias CompletionHandler = (Error?) -> Void
    
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
    
    var searchedMovies: [MovieRepresentation] = []
    
    
    // MARK: - PUT
    func put(movie: MovieRepresentation,completion: @escaping CompletionHandler = {_ in } ) {
        var newMovie = movie
          let identifier = movie.identifier ?? UUID()
          
        let  putURL = firebaseBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
              
          var requestURL = URLRequest(url:putURL )
          requestURL.httpMethod = HTTPMethod.PUT.rawValue
         
         
          let jsonEncoder = JSONEncoder()
      
          do {
           
       
            newMovie.identifier = identifier
              requestURL.httpBody = try jsonEncoder.encode(newMovie)
              
          } catch let error as NSError {
              print(error.localizedDescription)
              completion(nil)
              return
          }
    
          URLSession.shared.dataTask(with: requestURL) { (_, _, error) in
              if let error = error {
                  NSLog("Error sending data to sever: \(error)")
                  completion(error)
                  return
              }
                  completion(nil)
              
          }.resume()
          
      }
    
    
    
   // MARK: - DELETE
    
    
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = {_ in  }) {
          guard let uuid = movie.identifier else {
              completion(NSError())
              return
          }
          let requestURL = firebaseBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
          var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.DELETE.rawValue
          
          URLSession.shared.dataTask(with: request) { (data, response, error) in
              print(response!)
              completion(error)
          }.resume()
          
      
      }
    
    
    
    // MARK: - Fetch movies from Sever
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
