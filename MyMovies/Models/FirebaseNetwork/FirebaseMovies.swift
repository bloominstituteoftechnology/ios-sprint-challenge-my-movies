//
//  FirebaseMovies.swift
//  MyMovies
//
//  Created by Aaron Cleveland on 1/31/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

class FirebaseMovies {
    let baseURL = URL(string: "https://fir-movies-65ade.firebaseio.com/")!
    
//    typealias completionWithError = (Error?) -> ()
    
    func fetchFirebaseMovieFromServer(completion: @escaping (Error?) -> Void) {
        let requestURL = baseURL.appendingPathExtension("json")
        let request = URLRequest(url: requestURL)
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error fetching task: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                print("No data returned from task")
                completion(error)
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do {
                let decoded = try jsonDecoder.decode([String:MovieRepresentation].self, from: data).map { $0.value }
                self.updateFirebaseMovie(with: decoded)
            } catch {
                print("Error decoding data into object: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func sendFirebaseMovieToServer(movie: Movie, completion: @escaping () -> Void = {}) {
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = baseURL.appendingPathComponent(identifier.uuidString).appendingPathComponent("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        guard let movieRepresentation = movie.movieRepresentation else {
            print("Movie representation is not found")
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
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("error putting data:\(error)")
                completion()
                return
            }
            completion()
        }.resume()
    }
    
    func updateFirebaseMovie(with representation: [MovieRepresentation]) {
        let identifiersToFetch = representation.map { $0.identifier }
        let representationByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representation))
        
        var movieToCreate = representationByID
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.performAndWait {
            do {
                let existingMovie = try context.fetch(fetchRequest)
                for movie in existingMovie {
                    guard let identifier = movie.identifier,
                        let representation = representationByID[identifier] else {
                            continue
                    }
                    movie.title = representation.title
                    movie.hasWatched = representation.hasWatched ?? false
                    movieToCreate.removeValue(forKey: identifier)
                }
                for representation in movieToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
                
                try CoreDataStack.shared.save(context: context)
            } catch {
                print("Error")
            }
        }
    }
    
    func deleteFirebaseMovie(movie: Movie, completion: @escaping () -> Void = {}) {
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = baseURL.appendingPathExtension("json").appendingPathComponent(identifier.uuidString)
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
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
            print("Error deleting object: \(error)")
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            print("Error encoding movie rep: \(error)")
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
}
