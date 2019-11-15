//
//  MyMoviesController.swift
//  MyMovies
//
//  Created by morse on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MyMoviesController {
    // Mine: 1d24c, LS: 3f211
    let baseURL = URL(string: "https://movies-f5d2a.firebaseio.com/")!
    
    struct HTTPMethod {
        static let get = "GET"
        static let put = "PUT"
        static let post = "POST"
        static let delete = "DELETE"
    }
    
    //    init() {
    //        APIController.fetchTasksFromServer()
    //    }
    
    // Fetch Tasks from Firebase
    
    // MARK: - Task Actions
    
    func fetchMyMoviesFromServer(completion: @escaping (Error?) -> Void) {
        
        // Set up the URL
        
        let requestURL = baseURL.appendingPathExtension("json")
        
        // Create URL request
        
        let request = URLRequest(url: requestURL)
//        print(request)
        // Perform the data task
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            //            print(request)
            if let error = error {
                print("Error fetching tasks: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data returned from data task.")
                completion(nil)
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do {
                let decoded = try jsonDecoder.decode([String: MovieRepresentation].self, from: data).map { $0.value }
                self.updateTasks(with: decoded)
                completion(nil)
            } catch {
                print("Unable to decode data into object of type [MovieRepresentation]: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func sendMyMovieToServer(movie: Movie, completion: @escaping () -> Void = { }) {
        
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put
        
        guard let movieRepresentation = movie.movieRepresentation else {
            print("Movie Representation is nil")
            completion()
            return
        }
        
        do {
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            print("Error encoding movie representation: \(error)")
            completion()
            return
        }
        print(request)
        URLSession.shared.dataTask(with: request) { _, _, error in
            
            if let error = error {
                print("Error PUTting data: \(error)")
                completion()
                return
            }
            
            completion()
        }.resume()
    }
    
    func deleteMovie(_ movie: Movie, completion: @escaping () -> Void = { }) {
        
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete
        
        guard let movieRepresentation = movie.movieRepresentation else {
            print("Movie Representation is nil")
            completion()
            return
        }
        
        let context = CoreDataStack.shared.mainContext
        
        do {
            context.delete(movie)
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
        } catch {
            context.reset()
            print("Error deleting object from managed object context: \(error)")
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
//            print(String(data: request.httpBody!, encoding: .utf8))
        } catch {
            print("Error encoding movie representation: \(error)")
            completion()
            return
        }
        print(request)
        URLSession.shared.dataTask(with: request) { _, _, error in
            
            if let error = error {
                print("Error PUTting data: \(error)")
                completion()
                return
            }
            
            completion()
        }.resume()
    }
    
    // MARK: - Private Methods
    
    func updateTasks(with representations: [MovieRepresentation]) {
        
        // Which representations do we already have in Core Data?
        
        let identifiersToFetch = representations.map { $0.identifier }
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        
        // Make a mutable copy of the dictionary above
        
        var moviesToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        // Only fetch tasks with these identifiers
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch) // or potentially "identifier NOT IN %@"
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            
            
            
            do {
                let existingMovies = try context.fetch(fetchRequest)
                
                // Update the ones we do have
                
                for movie in existingMovies {
                    
                    // Grab the TaskRepresentation that corresponds to this task
                    guard let identifier = movie.identifier,
                        let representation = representationsByID[identifier] else { continue }
                    // This can be abstracted out to another function
                    movie.title = representation.title
                    movie.hasWatched = representation.hasWatched ?? false
                    
                    
                    moviesToCreate.removeValue(forKey: identifier)
                }
                
                // Figure out which ones we don't have
                
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
