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
    
    // MARK: - Initializers
    init() {
        fetchEntriesFromServer()
    }
    
    // MARK: - Properties
       
       var searchedMovies: [MovieRepresentation] = []
       
       static let shared = MovieController()
       
       let firebaseURL = URL(string: "https://mymovies-9dcfc.firebaseio.com/")!
       typealias CompletionHandler = (Error?) -> Void
       
       private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
       private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
       let MC = CoreDataStack.shared.mainContext
    
    
     //MARK: - Methods
        
        
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
        
        private func updateMovies(with representations: [MovieRepresentation]) throws {
            let moviesWithID = representations.filter { $0.identifier != nil}
            let identifiersToFetch = moviesWithID.compactMap { $0.identifier }
            let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
            var moviesToCreate = representationsByID

            let fetchRequest: NSFetchRequest = Movie.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)

            let context = CoreDataStack.shared.container.newBackgroundContext()

            context.perform {
                do {
                    let existingMovies = try context.fetch(fetchRequest)

                    for movie in existingMovies {
                        guard
                            let id = movie.identifier,
                            let representation = representationsByID[id]
                            else { let MC = CoreDataStack.shared.mainContext
                                MC.deleteMovie(movie: movie)
                                continue
                        }
                        self.updateMovie(movie: movie, with: representation)
                        moviesToCreate.removeValue(forKey: id)
                    }
                    for representation in moviesToCreate.values {
                        let _ = Movie(movieRepresentaion: representation, context: context)
                    }
                } catch {
                    NSLog("Error fetching tacks for UUIDs: \(error)")
                }
            }
            do{
            try CoreDataStack.shared.save(context: context)
        } catch {
            print("error saving movie: \(error)")
        }
    }
        
        
        // MARK: - CRUD
           
           // CREATE
        func createMovie(title: String, identifier: UUID = UUID(), hasWatched: Bool) {
               let movie = Movie(title: title)
               put(movie: movie)
               
           }
           
           // UPDATE
        func updateMovie(movie: Movie, representation: MovieRepresentation) {
            movie.title = representaion.title
            movie.hasWatched = hasWatched
               
               
           }
           
           // DELETE
           
        func deleteMovie(for movie: Movie) {
            deleteEntryFromServer(movie: movie) { (error) in
                guard error == nil else {
                    print("Error deleting entry from server: \(String(describing: error))")
                    return
                }
            
            
                self.MC.delete(entry)
                
            }
        }
        
       
    

    
    
    // MARK: - Firebase Methods
    
    func fetchEntriesFromServer(completion: @escaping CompletionHandler = { _ in  }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
                  
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
                      if let error = error {
                          NSLog("Error fetching tasks from Firebase: \(error)")
                          completion(error)
                          return
                        
            }
            guard let data = data else {
                NSLog("No data returned from Firebase")
                completion(NSError())
                return
            }
            
           
            let jsonDecoder = JSONDecoder()
            do {
                let decodedMovies = try jsonDecoder.decode([String : MovieRepresentation].self, from: data)
                vat movieRepresentations = 
               
                try self.updateMovies(with: decodedMovies)
                completion(nil)
            } catch {
                NSLog("Error decoding entry representations from Firebase: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    func put(movie: Movie, completion: @escaping CompletionHandler = {_ in }) {
        identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
    
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
    
        guard let entryRepresentation = entry.entryRepresentation else {
            NSLog("No entry, Entry == nil")
            completion(nil)
            return
        }
    
        do  {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(entryRepresentation)
    
        } catch {
            NSLog("Can't encode entry representation")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error fetching tasks from Firebase: \(error)")
                completion(error)
                return
            }
            completion(nil)

        }.resume()
    }
       
}
   
