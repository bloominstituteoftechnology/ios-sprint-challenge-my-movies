//
//  MyMoviesController.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_201 on 12/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MyMoviesController {
    let baseURL = URL(string: "")!
    
    struct HTTPMethod {
        static let get = "GET"
        static let put = "PUT"
        static let post = "POST"
        static let delete = "DELETE"
    }
    
    func fetchMyMoviesFromServer(completion: @escaping (Error?) -> Void) {
        let requestURL = baseURL.appendingPathExtension("json")
        
        let request = URLRequest(url: requestURL)
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error fetching task: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No daa returned from data task.")
                completion(nil)
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do {
                let decoded  = try jsonDecoder.decode([String: MovieRepresentation].self, from: data).map { $0.value }
                self.updateTask(with: decoded)
                completion(nil)
            }catch {
                print("Unable to decode data into object o ftype [MovieRepresentation]: \(error) ")
                completion(nil)
            }
        }.resume()
    }
    
    func sendMyMovieToServer(movie: Movie, completion: @escaping () -> Void = { }) {
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
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
        }catch {
            print("Error encoding movie representation: \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print(" Error PUTting data: \(error)")
                completion()
                return
            }
            
            completion()
        }.resume()
    }
    
    func deleteMovies(_ movie: Movie, completion: @escaping () -> Void = { }) {
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
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
        }catch {
            context.reset()
            print("Error deleted object context: \(error)")
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        }catch {
            print("Error encoding movie representation: \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("Error putting data: \(error)")
                completion()
                return
            }
            
            completion()
        }.resume()
    }
    
    func updateTask(with representations: [MovieRepresentation]) {
        
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
                    let representation = representationsByID[identifier] else
                    { continue }
                    
                    movie.title = representation.title
                    movie.hasWatched = representation.hasWatched ?? false
                    
                    moviesToCreate.removeValue(forKey: identifier)
                }
                
                for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
                
                try CoreDataStack.shared.save(context: context)
            }catch {
                print("Error fetching tasks from persistence store: \(error)")
            }
        }
    }
}
