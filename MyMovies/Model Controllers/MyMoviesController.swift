//
//  MyMoviesController.swift
//  MyMovies
//
//  Created by Keri Levesque on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData


class MyMoviesController {
    
    let baseURL = URL(string: "https://movies-ef034.firebaseio.com/")!
    
    struct HTTPMethod {
        static let get = "GET"
        static let put = "PUT"
        static let post = "POST"
        static let delete = "DELETE"
    }
    
    //MARK: Fetch
    
    func fetchMyMoviesFromServer(completion: @escaping (Error?) -> Void) {
        
        let requestURL = baseURL.appendingPathExtension("json")
        let request = URLRequest(url: requestURL)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching tasks: \(error)")
                completion(nil)
                return
            }
            guard let data = data else {
                print("No data returned from data task")
                completion(nil)
                return
            }
            let jsonDecoder = JSONDecoder()
            do {
                let decoded = try jsonDecoder.decode([String: MovieRepresentation].self, from: data).map { $0.value }
                self.updateTasks(with: decoded)
                completion(nil)
            } catch {
                print("Error decoding JSON data: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    //MARK: Send
    
    func sendMyMoviesToServer(movie: Movie, completion: @escaping () -> Void = { }) {
        
        let identifer = movie.identifier ?? UUID()
        movie.identifier = identifer
        
        let requestURL = baseURL
            .appendingPathComponent(identifer.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put
        
        guard let movieRepresentation = movie.movieRepresentation else {
            print("Movie representation is nil")
            completion()
            return
        }
        do {
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            print("Error encoding movies \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("Error PUTing data: \(error)")
                completion()
                return
            }
            completion()
        }.resume()
    }
    
    //MARK: Delete
    
    func deleteMovie(_ movie: Movie, completion: @escaping () -> Void = { }) {
        
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete
        
        guard let movieRepresentation = movie.movieRepresentation else {
            print("Movie representation is nil")
            completion()
            return
        }
        let context = CoreDataStack.shared.mainContext
        
        do {
            context.delete(movie)
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
        } catch {
            context.reset()
            print("Error deleting movie \(error)")
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            print("Error encoding movie \(error)")
            completion()
            return
        }
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("Error PUTing data \(error)")
                completion()
                return
            }
            completion()
        }.resume()
    }

    func updateTasks(with representations: [MovieRepresentation]) {
            
            let identifiersToFetch = representations.map { $0.identifier }
            
            let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
            
            var moviesToCreate = representationsByID
            
            let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
            
            let context = CoreDataStack.shared.container.newBackgroundContext()
            
            context.performAndWait {
                
                do {
                    let existingMovies = try context.fetch(fetchRequest)
                    
                    for movie in existingMovies {
                        guard let identifier = movie.identifier,
                        let representation = representationsByID[identifier] else { continue }
    
                        movie.title = representation.title
                        movie.hasWatched = representation.hasWatched ?? false
                        
                        
                        moviesToCreate.removeValue(forKey: identifier)
                    }
                    
                    for representation in moviesToCreate.values {
                        Movie(movieRepresentation: representation, context: context)
                    }
                    try CoreDataStack.shared.save(context: context)
                } catch {
                    print("Error fetching tasks from persistent store: \(error)")
                }
            }
        }




}
