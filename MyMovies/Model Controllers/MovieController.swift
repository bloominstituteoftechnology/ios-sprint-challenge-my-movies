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
    
    
    init() {
        fetchMoviesFromSever()
    }
    
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
    
    func fetchMoviesFromSever(completion: @escaping CompletionHandler = { _ in }) {
             let requestURL = firebaseBaseURL.appendingPathExtension("json")
         
             
             URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
                 if let error = error {
                     NSLog("Error fetching entries from Firebase: \(error)")
                     completion(error)
                     return
                 }
                 
                 guard let data = data else {
                     NSLog("No data returned from Firebase")
                     completion(NSError())
                     return
                 }
                 
                 do {
                  let jsonDecoder = JSONDecoder()
                     let moviesRepresentation = Array(try jsonDecoder.decode([String : MovieRepresentation].self, from: data).values)
                     try self.updateMovies(with: moviesRepresentation)
                     completion(nil)
                 } catch {
                     NSLog("Error decoding entries representations from Firebase: \(error)")
                     completion(error)
                 }
             }.resume()
         }
    
    
    
    //MARK: - Update movies
    
      private func updateMovies(with representations: [MovieRepresentation]) throws {
        
            let moviesWithID = representations.filter { $0.identifier != nil }
        
        let identifiersToFetch = moviesWithID.compactMap { $0.identifier ?? UUID() }
        
            let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
        
            var entriesToCreate = representationsByID
            
         
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@",identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            do {
                let existingMovies = try context.fetch(fetchRequest)
                
               
                for movie in existingMovies{
                    
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else { continue }
                    
                    self.update(movie: movie, with: representation)
                    entriesToCreate.removeValue(forKey: id)
                  
                }
                
                for representation in entriesToCreate.values {
                  
                    Movie(movieRepresentation: representation, context: context)
                  
                }
            } catch {
                NSLog("Error fetching tasks for UUIDs: \(error)")
            }
            
        }
                    
           
        try CoreDataStack.shared.save(context: context)
  
        }
        
        private func update(movie: Movie, with representation: MovieRepresentation) {
        
            movie.title = representation.title
        }
    
    
    // MARK: - Toggle Watch/ Unwatch
    
    func updateMovieStatus(with newStatus: Bool, movie: MovieRepresentation) {
        var newMoview = movie
        newMoview.hasWatched = newStatus
            
            put(movie: newMoview)
    
            
        }
    
    
    
    
    
    
    
    
    
}
