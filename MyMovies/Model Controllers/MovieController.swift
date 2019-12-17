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
    
    
    
    private let fireBaseURL = URL(string: "https://mymovies-ca563.firebaseio.com/")!
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
    
    init() {
        fetchEntriesFromServer()
    }
    
    func fetchEntriesFromServer(completion: @escaping CompletionHandler = { _ in }) {
            let requestURL = fireBaseURL.appendingPathExtension("json")
            URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
                guard error == nil else {
                    print("Error fetching tasks: \(error!)")
                    completion(error)
                    return
                }
                guard let data = data else {
                    print("no data returned by data task")
                    completion(NSError())
                    return
                }
                do{
                    let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                    
                    try self.updateMovies(with: movieRepresentations)
                    
                    completion(nil)
                } catch {
                    print("Error decoding tasks representations: \(error)")
                    completion(error)
                    return
                }
                
            }.resume()
        }
        
        
        func put(movie: Movie, completion: @escaping () -> Void = { }){
            
            let uuid = movie.identifier ?? UUID()
            let requestURL = fireBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
            var request = URLRequest(url: requestURL)
            request.httpMethod = "PUT"
            
            do {
                guard let representation = movie.movieRepresentation else {
                    completion()
                    return
                }

                movie.identifier = uuid
                request.httpBody = try JSONEncoder().encode(representation)
            } catch {
                print("Error encoding task \(movie): \(error)")
                completion()
                return
            }
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard error == nil else {
                    print("Error PUTing entry to server: \(error!)")
                    completion()
                    return
                }
                completion()
            }.resume()
        }
        
        func create(title: String) {
               
               let movie = Movie(title: title)
               put(movie: movie)
               CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
               
           }
           
           func update(movie: Movie, title: String, hasWatched: Bool) {
               
               movie.title = title
               movie.hasWatched = hasWatched
               put(movie: movie)
               CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
               
               
           }
           
           private func updateMovies(with representations: [MovieRepresentation]) throws {
               
               let moviesWithID = representations.filter { $0.identifier != nil }
               let identifiersToFetch = moviesWithID.compactMap { $0.identifier! }
               let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
               var moviesToCreate = representationsByID
               
            let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
               let context = CoreDataStack.shared.container.newBackgroundContext()
               
               context.perform {
                   do {
                       let exsistingMovies = try context.fetch(fetchRequest)
                       for movie in exsistingMovies {
                           guard let id = movie.identifier,
                               let representation = representationsByID[id] else {
                                   let moc = CoreDataStack.shared.mainContext
                                   moc.delete(movie)
                                   continue
                           }
                           
                        movie.title = representation.title
                        movie.hasWatched = representation.hasWatched!
                           
                        moviesToCreate.removeValue(forKey: id)
                       }
                       for representation in moviesToCreate.values {
                        Movie(movieRepresentation: representation, context: context)
                       }
                   } catch {
                       print("Error fetching tasks for UUIDs: \(error)")
                   }
               }
               
               
               CoreDataStack.shared.save(context: context)
           }
           
        
        
        
        
        func delete(for movie: Movie) {
            CoreDataStack.shared.mainContext.delete(movie)
            deleteEntryFromServer(movie)
            CoreDataStack.shared.save()
        }
        
        func deleteEntryFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in}) {
            guard let identifier = movie.identifier else {
                completion(NSError())
                return
            }
            let requestURL = fireBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
            var request = URLRequest(url: requestURL)
            request.httpMethod = "DELETE"
            
            URLSession.shared.dataTask(with: request) { (data, _, error) in
                if let error = error {
                    NSLog("Error deleting entry from server: \(error)")
                    completion(error)
                    return
                }
                completion(nil)
            }.resume()
        }
        
        // MARK: - Properties
        
        var searchedMovies: [MovieRepresentation] = []
    }
