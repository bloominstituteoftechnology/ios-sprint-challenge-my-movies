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
    
    func updateMovies(with representations: [MovieRepresentation]) {
        
        let identifiersToFetch = representations.map({ $0.identifier })
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        
        var tasksToCreate = representationsByID
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            
            do {
                
                let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
                
                fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
                
                let existingTasks = try context.fetch(fetchRequest)
                
                for task in existingTasks {
                    
                    guard let identifier = task.identifier,
                        let representation = representationsByID[identifier] else { continue }
                    
                    task.title = representation.title
                    task.identifier = representation.identifier
                    task.hasWatched = representation.hasWatched ?? false
                    
                    tasksToCreate.removeValue(forKey: identifier)
                    
                }
                
                for representation in tasksToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
                
                CoreDataStack.shared.save(context: context)
                
            } catch {
                NSLog("Error fetching tasks from persistent store: \(error)")
            }
            
        }
        
    }
    
    func put(movie: Movie, completion: @escaping () -> Void = { }) {
        
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathComponent("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard let movieRepresentation = movie.movieRepresentation else {
            NSLog("Movie Representation is nil")
            completion()
            return
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            NSLog("Error encoding move representation: \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            
            if let error = error {
                NSLog("Error PUTting movie: \(error)")
                completion()
                return
            }
            
            completion()
            
        }.resume()
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping () -> Void = { }) {
        
        guard let identifier = movie.identifier else {
            completion()
            return
        }
        
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathComponent("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) {(data, _, error) in
            
            if let error = error {
                NSLog("Error deleting movie \(movie.title ?? "") from server: \(error)")
                completion()
                return
            }
            
            completion()
            
        }.resume()
        
    }
    
    func createMovie(with title: String, identifier: UUID, hasWatched: Bool?, context: NSManagedObjectContext) {
        
        let movie = Movie(title: title, identifier: identifier, hasWatched: hasWatched, context: context)
        CoreDataStack.shared.save(context: context)
        put(movie: movie)
        
    }
    
    func updateMovie(movie: Movie, with title: String, hasWatched: Bool, context: NSManagedObjectContext) {
        
        movie.title = title
        movie.hasWatched = hasWatched
        CoreDataStack.shared.save(context: context)
        put(movie: movie)
        
    }
    
    func delete(movie: Movie, context: NSManagedObjectContext) {
        
        context.performAndWait {
            deleteMovieFromServer(movie)
            context.delete(movie)
            CoreDataStack.shared.save(context: context)
        }
        
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
