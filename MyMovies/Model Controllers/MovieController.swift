//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HttpMethod: String {
    case put = "PUT"
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
}


class MovieController {
    
     // MARK: - Properties
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let databaseURL = URL(string:"https://mymovies-9f7f0.firebaseio.com/")!
    let session = URLSession(configuration: .default)
    var searchedMovies: [MovieRepresentation] = []
    
    init() {
        fetchMoviesFromServer()
    }
    
    // MARK: - C.R.U.D Methods
    func addMovie(withTitle title: String, context: NSManagedObjectContext) {
        let movie = Movie(title: title, context: CoreDataStack.shared.mainContext)
        putMovieInDatabase(movie)
        CoreDataStack.shared.mainContext.saveChanges()
    }
    
    func deleteMovie(_ movie: Movie) {
        deleteFromServer(movie)
        CoreDataStack.shared.mainContext.delete(movie)
        CoreDataStack.shared.mainContext.saveChanges()
    }
    
    func updateMovie(_ movie: Movie) {
        movie.hasWatched = !movie.hasWatched
        putMovieInDatabase(movie)
        CoreDataStack.shared.mainContext.saveChanges()
    }

    //MARK: - put in database
    private func putMovieInDatabase(_ movie: Movie, completion: @escaping() -> Void = {}) {
        let movieIdentifier = movie.identifier ?? UUID()
               movie.identifier = movieIdentifier
        
        let firebaseURL = databaseURL
        .appendingPathComponent(movieIdentifier.uuidString)
        .appendingPathExtension("json")
        
        var request = URLRequest(url: firebaseURL)
        request.httpMethod = HttpMethod.put.rawValue
        
        do {
            request.httpBody = try JSONEncoder().encode(movie.movieRepresentation)
        } catch {
            NSLog("failed to put film on database")
        }
        
        session.dataTask(with: request) { (_, response, error) in
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {return}
            
            if let error = error {
                NSLog("failed to put in database: \(error.localizedDescription)")
            }
        }.resume()
    }

    //MARK: - delete From Server
    private func deleteFromServer(_ movie: Movie, completion: @escaping() -> Void = {}) {
        guard let identifier = movie.identifier else {return}
    
        let firebaseURL = databaseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        var request = URLRequest(url: firebaseURL)
        request.httpMethod = HttpMethod.delete.rawValue
        session.dataTask(with: request) { (_, _, error) in
            if let error = error {
                 NSLog("failed to delete \(movie.title ?? "")from server: \(error)")
            }
        }.resume()
    }

}

/// tthis extension is for the firebase movie api
extension MovieController {
    
    //MARK: - fetching from server
    func fetchMoviesFromServer(completion: @escaping()-> Void = {}) {
        
        let fireBaseURL = databaseURL.appendingPathExtension("json")
        
        let request = URLRequest(url: fireBaseURL)
        
        session.dataTask(with: request) { (data, _, error) in
            
            if let error = error as NSError? {
                NSLog("error fetching from server: \(error.localizedDescription)")
                completion()
            }
            
            guard let data = data else {return completion()}
            
            do {
                let decoder = JSONDecoder()
                let movies = try decoder.decode([String: MovieRepresentation].self, from: data).map({$0.value})
                self.update(with: movies)
            } catch {
                NSLog("error decoding data from API: \(error.localizedDescription)")
                completion()
            }
            
        }.resume()
    }
    
    //MARK: - update movies from server
    private func update(with movieRep: [MovieRepresentation]) {
        
        let fetchedIdentifiers = movieRep.map({$0.identifier})
        let movieRepId = Dictionary(uniqueKeysWithValues: zip(fetchedIdentifiers, movieRep))
        var moviesToBeCreated = movieRepId
        
        let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
        
        backgroundContext.performAndWait {
            do {
                let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "identifier IN %@", fetchedIdentifiers)
                let existingMovies = try backgroundContext.fetch(fetchRequest)
                
                for movie in existingMovies {
                    
                    guard let identifier = movie.identifier,
                    let movieRepresentation = movieRepId[identifier] else {continue}
                    movie.hasWatched = movieRepresentation.hasWatched ?? false
                    movie.title = movieRepresentation.title
                    
                    moviesToBeCreated.removeValue(forKey: identifier)
                }
                for movieRep in moviesToBeCreated.values {
                    Movie(movieRepresentation: movieRep, context: backgroundContext)
                }
                
                CoreDataStack.shared.mainContext.save(context: backgroundContext)
            } catch {
                NSLog("error fetching from persistence store: \(error.localizedDescription)")
            }
        }
    }
}

/// this extension for the Movie API.
extension MovieController {
   
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
       
}
