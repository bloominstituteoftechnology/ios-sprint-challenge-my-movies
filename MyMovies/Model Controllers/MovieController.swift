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
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    private let moviesListURL = URL(string: "https://mymovies-bb590.firebaseio.com/")!
    
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
    
    func put(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let identifier =  movie.identifier else {
            completion(nil)
            return
        }
        
        
        let baseWithIdentifierURL = moviesListURL.appendingPathComponent(identifier.uuidString)
        let requestURL = baseWithIdentifierURL.appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        let jsonEncoder = JSONEncoder()
        
        do {
            CoreDataStack.shared.save()
            let data = try jsonEncoder.encode(movie.movieRepresentation)
            request.httpBody = data
        } catch {
            print("Error encoding the data: \(error)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            
            if let error = error {
                print("General error: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
        
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let identifier = movie.identifier else {
            completion(nil)
            return
        }
        
        let baseWithIdentifierURL = baseURL.appendingPathComponent(identifier.uuidString)
        let requestURL = baseWithIdentifierURL.appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            
            if let error = error {
                print("Error deleting entry object: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            
        }.resume()
    }
    
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void = { _ in })  {
           
           let requestURL = moviesListURL.appendingPathExtension("json")
           var request = URLRequest(url: requestURL)
           
           request.httpMethod = "GET"
           
           URLSession.shared.dataTask(with: request) { (data, _, error) in
               
               if let error = error {
                   print("Error fetching entries: \(error)")
                   completion(error)
                   return
               }
               
               guard let data = data else {
                   completion(nil)
                   return
               }
               
               var movieRepresentations: [MovieRepresentation] = []
               
               let decoder = JSONDecoder()
               
               do {
                   let moviesDictionary = try decoder.decode([String: MovieRepresentation].self, from: data)
                   
                   for movie in moviesDictionary {
                       movieRepresentations.append(movie.value)
                   }
                   
                   self.updateMovies(with: movieRepresentations)
                   completion(nil)
               } catch {
                   print("Error decoding entry data: \(error)")
               }
               
           }.resume()
       }
    
    func updateMovies(with representations: [MovieRepresentation]) {
        
        let movieIdentifiers = representations.compactMap({ $0.identifier })
        var representationsByID = Dictionary(uniqueKeysWithValues: zip(movieIdentifiers, representations))
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", movieIdentifiers)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            do {
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let id = movie.identifier, let representaion = representationsByID[id] else {
                        continue
                    }
                    
                    self.update(movie: movie, movieRepresentation: representaion)
                    representationsByID.removeValue(forKey: id)
                }
                
                for representation in representationsByID.values {
                    let _ = Movie(movieRepresentation: representation, context: context)
                }
                
            } catch {
                print("Error fetching movies for identifiers: \(error)")
            }
        }
        
        CoreDataStack.shared.save(context: context)
    
    }
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    
    // MARK: - CRUD Functions
    
    func addMovie(_ movieRepresentation: MovieRepresentation) {
        let movie = Movie(title: movieRepresentation.title, hasWatched: false, identifier: UUID())
        put(movie: movie)
        CoreDataStack.shared.save()
    }
    
    func updateStatus(for movie: Movie) {
        if movie.hasWatched == true {
            movie.hasWatched = false
        } else if movie.hasWatched == false {
            movie.hasWatched = true
        }
        put(movie: movie)
        CoreDataStack.shared.save()
    }
    
//    func delete(movie: Movie) {
//        let moc = CoreDataStack.shared.mainContext
//        moc.delete(movie)
//        deleteMovieFromServer(movie: movie)
//
//
//        CoreDataStack.shared.save()
//
//    }
    
    func update(movie: Movie, movieRepresentation: MovieRepresentation) {
        movie.title = movieRepresentation.title
    }
    
}
