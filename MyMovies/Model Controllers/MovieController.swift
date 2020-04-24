//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData
enum NetworkError: Error {
    case noIdentifier, otherError, noData, noDecode, noEncode, noRep
}
enum HTTPMethod: String {
    case put = "PUT"
    case delete = "DELETE"
}
class MovieController {
    
 
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
   private let baseURL2 = URL(string: "https://mynewmovie-54c0e.firebaseio.com/")!
    
    init() {
           fetchMovieFromServer()
       }
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
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
    
         func fetchMovieFromServer(completion: @escaping CompletionHandler = {_ in}) {
              let requestURL = baseURL2.appendingPathExtension("json")
              
              URLSession.shared.dataTask(with: requestURL) { data, response, error in
                  if let error = error {
                      NSLog("Unable to fetch entry: \(error)")
                      completion(.failure(.otherError))
                      return
                  }
                  guard let data = data else {
                      NSLog("No data to return from fetch")
                      completion(.failure(.noData))
                      return
                  }
                  do {
                      let movieRepresentation = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                      try self.updateEntries(with: movieRepresentation)
                      completion(.success(true))
                  } catch {
                      NSLog("Error decoding tasks from server: \(error)")
                  }
              }.resume()
          }
          
          func sendMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
              guard let uuid = movie.identifier else {
                  completion(.failure(.noIdentifier))
                  return
              }
              
              let requestURL = baseURL2.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
              var request = URLRequest(url: requestURL)
              request.httpMethod = HTTPMethod.put.rawValue
              
              do {
                guard let representation = movie.movieRepresentation else {
                      completion(.failure(.noRep))
                      return
                  }
                  request.httpBody = try JSONEncoder().encode(representation)
                  
              } catch {
                  NSLog("Error encoding \(movie): \(error)")
                  completion(.failure(.noEncode))
                  return
              }
              
              URLSession.shared.dataTask(with: request) { data, response, error in
                  if let error = error {
                      NSLog("Error in getting data: \(error)")
                      completion(.failure(.noData))
                  }
                  
                  //            MARK: - Data handeling
                  
                  
                  
                  
                  //            MARK: - Response handeling
                  
                  
                  completion(.success(true))
              }.resume()
              
          }
          
    func deleteEntryFromServe(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
              guard let uuid = movie.identifier else {
                  completion(.failure(.noIdentifier))
                  return
              }
              
              let requestURL = baseURL2.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
              var request = URLRequest(url: requestURL)
              request.httpMethod = HTTPMethod.delete.rawValue
              
              URLSession.shared.dataTask(with: request) { data, response, error in
                  if let error = error {
                      NSLog("Error in getting data: \(error)")
                      completion(.failure(.noData))
                  }
            
                  
                  completion(.success(true))
              }.resume()
          }
          
          private func update(movie: Movie, with representation: MovieRepresentation) {
              movie.title = representation.title
            movie.identifier = representation.identifier
            movie.hasWatched = representation.hasWatched ?? false
          }
          
          private func updateEntries(with representations: [MovieRepresentation]) throws {
             let tasksByID = representations.filter { $0.identifier != nil }
              let identifiersToFetch = tasksByID.compactMap { $0.identifier }
              let representationByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
              var entryToCreate = representationByID
              let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
              
              fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
              
              let context = CoreDataStack.shared.container.newBackgroundContext()
              context.perform {
                  
              do {
                  let existingEntries = try context.fetch(fetchRequest)
                             
                             for movie in existingEntries {
                                 guard let id = movie.identifier,
                                     let representation = representationByID[id] else { continue }
                                 self.update(movie: movie, with: representation)
                              entryToCreate.removeValue(forKey: id)
                             }
                  for representation in entryToCreate.values {
                     Movie(movieRepresentation: representation, context: context)
                  }
                 try context.save()
              } catch {
                 NSLog("Error fetching entry with uUIDs: \(identifiersToFetch), with error: \(error)")
              }
              }
          }
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
