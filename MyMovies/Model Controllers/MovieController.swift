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
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    private let firebaseURL = URL(string: "https://mymovies-lambdasprintchallenge.firebaseio.com/")!
    
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
        
        let identifier = movie.identifier ?? UUID()
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var representation = movie.movieRepresentation else {
                completion(nil)
                return
            }
            representation.identifier = identifier
            movie.identifier = identifier
            
            CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
            
        } catch {
            print("Error encoding task: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("Error fetching saved movies: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func delete(_ movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let identifier = movie.identifier else {
            completion(nil)
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            print("Deleted task with UUID: \(identifier.uuidString)")
            completion(error)
        }.resume()
    }
    
    func updateMovies(with representations: [MovieRepresentation]) {
        let moviesWithID = representations.filter({ $0.identifier != nil })
        let idsToFetch = moviesWithID.compactMap({ $0.identifier })
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(idsToFetch, moviesWithID))
        
        var moviesToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", idsToFetch)
        
        let context  = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            do {
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else { continue }
                    
                    self.update(movie: movie, with: representation)
                    
                    moviesToCreate.removeValue(forKey: id)
                }
                
                for representation in moviesToCreate.values {
                    let _ = Movie(movieRepresentation: representation, context: context)
                }
            } catch {
                print("Error fetching movies for UUIDS: \(error)")
            }
        }
        
        CoreDataStack.shared.save(context: context)
    }
    
    func create(movieWithTitle: String) {
        let movie = Movie(title: movieWithTitle, identifier: UUID(), hasWatched: false)
        put(movie: movie)
    }
    
    func update(movie: Movie, with representation: MovieRepresentation) {
        
        guard let hasWatched = representation.hasWatched else { return }
        movie.title = representation.title
        movie.identifier = representation.identifier
        movie.hasWatched = hasWatched
        put(movie: movie)
        
    }
}

//extension MovieController: AddMovieDelegate {
//    func movieWasAdded(_ movieTitle: String) {
//        create(movieWithTitle: movieTitle)
//    }
//}
