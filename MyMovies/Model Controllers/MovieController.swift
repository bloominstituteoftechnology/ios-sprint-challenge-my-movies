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
    
    typealias completionHandler = (Error?) -> Void
    

    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    
init() {
     fetchMoviesFromServer()
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
    }
    
    func fetchMoviesFromServer(completion: @escaping completionHandler = { _ in }) {
           let requestURL = baseURL.appendingPathExtension("json")
           var request = URLRequest(url: requestURL)
           request.httpMethod = "GET"
           
           URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
               //if you want it to not to continue. if let, else continues in the code.
               guard error == nil else {
                   print("Error fetching tasks: \(error!)")
                   DispatchQueue.main.async {
                       completion(error)
                   }
                   return
               }
               
               guard let data = data else {
                   print("No data returned by data task")
                   DispatchQueue.main.async {
                       completion(NSError())
                   }
                   
                   return
               }
               
               do {
                   //we want the values of the dictionary
                   let taskRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                   // Update tasks
                   try self.updateMovies(with: taskRepresentations)
                   DispatchQueue.main.async {
                       completion(nil)
                   }
               } catch {
                   print("Error decoding task representations: \(error)")
                   DispatchQueue.main.async {
                       completion(error)
                   }
               }
           }.resume()
       }
    
    func updateMovies(with representations: [MovieRepresentation]) throws {
           let moviesWithID = representations.filter { $0.identifier != nil }
           //array of UUIDs. Removes any value that is nil
        let identifiersToFetch = representations.compactMap { $0.identifier }
           //creates a dictionary where key is UUID and the value is the task object
           let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
           var moviesToCreate = representationsByID
           
           let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
           fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
           
           let context = CoreDataStack.shared.container.newBackgroundContext()
           
           context.perform {
                    do {
                      let existingMovies = try context.fetch(fetchRequest)
                      
                      for movie in existingMovies {
                          guard let id = movie.identifier,
                              let representation = representationsByID[id] else { continue }
                          //from line 88. private func to keep code cleaner. Could have set values here
                          self.update(movie: movie, with: representation)
                          moviesToCreate.removeValue(forKey: id)
                      }
                      for representation in moviesToCreate.values {
                        Movie(movieRepresentation: representation, context: context)
                      }
                  } catch {
                      print("Error fetching task for UUIDs: \(error)")
                      
                  }
           }
           do {
               try CoreDataStack.shared.save(context: context)
           } catch {
               print("Error savind to database")
           }
          
       }
    
    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title =  representation.title
        movie.hasWatched = representation.hasWatched ?? false
    }
    // MARK: -  CRUD
    
    func deleteTaskFromServer(_ movie: Movie, completion: @escaping completionHandler = { _ in }) {
          
           CoreDataStack.shared.mainContext.perform {
            guard let uuid = movie.identifier else {
                       completion(NSError())
                       return
                   }
                   
            let requestURL = self.baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
                   var request = URLRequest(url: requestURL)
                   request.httpMethod = "DELETE"
                   
                   URLSession.shared.dataTask(with: request) { (_, _, error) in
                       guard error == nil else {
                           print("Error deleting task: \(error!)")
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
           }
       
    
    

}
