//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

class MovieController {
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    let firebaseURL = URL(string: "https://mymovies-2d3de.firebaseio.com/")!
    
    
    // MARK: - Methods
    
    func saveMovie(with title: String, identifier: UUID, hasWatched: Bool = false) -> Movie {
        let movie = Movie(title: title, identifier: identifier, hasWatched: hasWatched, context: CoreDataStack.shared.mainContext)
        saveToPersistentStore()
        put(movie: movie)
        return movie
    }
    
    func delete(movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        saveToPersistentStore()
    }
    
    func put(movie: Movie, completion: @escaping () -> Void = {}) {
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard let movieRepresentation = movie.movieRepresentation else {
            print("Movie representation is nil")
            completion()
            return
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            print("Error encoding movie representation: \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("Error PUTing movie: \(error)")
                completion()
                return
            }
            completion()
        }.resume()
        saveToPersistentStore()
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping (Error?) -> Void) {
        guard let uuid = movie.identifier else {
            completion(nil)
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            print("Deleted task with UUID: \(uuid.uuidString)")
            completion(error)
        }.resume()
    }
    
    func updateMovies(with representations: [MovieRepresentation]) {
        let identifiersToFetch = representations.compactMap({ $0.identifier })
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        
        var entriesToCreate = representationsByID
        
        do {
            let context = CoreDataStack.shared.mainContext
            let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
            
            let existingMovies = try context.fetch(fetchRequest)
            
            for movie in existingMovies {
                guard let identifier = movie.identifier,
                    let representation = representationsByID[identifier] else { continue }
                
                movie.title = representation.title
                movie.hasWatched = representation.hasWatched ?? false
                
                entriesToCreate.removeValue(forKey: identifier)
            }
            
            for representation in entriesToCreate.values {
                Movie(movieRepresentation: representation, context: context)
            }
            
            saveToPersistentStore()
        } catch {
            print("Error fetching entries from persistent store: \(error)")
        }
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
    
    func saveToPersistentStore() {
        CoreDataStack.shared.saveToPersistentStore()
    }
    
    
}
