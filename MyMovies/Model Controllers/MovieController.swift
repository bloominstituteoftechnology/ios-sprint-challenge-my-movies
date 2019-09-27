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
    
    static let sharedController = MovieController()
    init(){
        fetchMoviesFromFirebase()
    }
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://coredatasprintchallenge.firebaseio.com/")!
    
    // MARK: - Movie Search Networking Methods
    
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
    
    // MARK: - Firebase Network Methods
    
    func putMovie(movie: Movie, completion: @escaping () -> Void = { }) {
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard let movieRepresentation = movie.movieRepresentation else {
            NSLog("Movie Representation is nil on line \(#line) in \(#file)")
            completion()
            return
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            NSLog("Error encoding movie representation on line \(#line) in \(#file): \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTting movie on line \(#line) in \(#file): \(error)")
                completion()
                return
            }
            
            completion()
        }.resume()
        
    }
    
    func fetchMoviesFromFirebase(completion: @escaping () -> Void = {  }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movies from Firebase on line \(#line) in \(#file): \(error)")
                completion()
            }
            
            guard let data = data else {
                NSLog("Error fetching data on line \(#line) in \(#file)")
                completion()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let movieRepresentations = try decoder.decode([String: MovieRepresentation].self, from: data)
                let movieArray = movieRepresentations.map({ $0.value })
                self.updateMovie(with: movieArray)
            } catch {
                NSLog("Error decoding Movies from Firebase: \(error)")
            }
        }.resume()
    }
    
    // MARK: - Core Data Methods
    @discardableResult func createMovie(title: String, identifier: UUID = UUID(), hasWatched: Bool) -> Movie {
        let movie = Movie(title: title, identifier: identifier, hasWatched: hasWatched, context: CoreDataStack.shared.mainContext)
        CoreDataStack.shared.save()
        putMovie(movie: movie)
        
        return movie
    }
    
    func updateMovie(with representations: [MovieRepresentation]) {
        let identifiersToFetch = representations.compactMap({ $0.identifier })
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var moviesToCreate = representationsByID
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            do {
                let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
                let existingMovies = try context.fetch(fetchRequest)
                
                for movie in existingMovies {
                    guard let identifier = movie.identifier?.uuidString,
                        let representation = representationsByID[identifier] else { return }
                    
                    movie.title = representation.title
                    movie.hasWatched = representation.hasWatched ?? false
                    movie.identifier = UUID(uuidString: representation.identifier!)
                    
                    moviesToCreate.removeValue(forKey: identifier)
                }
                
                for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                }
                
                CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error fetching movies on line \(#line) in \(#file): \(error)")
            }
        }
    }
    
    func deleteMovie(movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        CoreDataStack.shared.save()
    }
    
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
