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
    
    
//MARK: - properties
    var searchedMovies: [MovieRepresentation] = []
    private let dataBaseUrl = URL(string: "https://mymovies-9f7f0.firebaseio.com/")!
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    
//MARK: - methods
    
    //create method
   @discardableResult func createMovie(with title: String) {
        let movie = Movie(title: title, context: CoreDataStack.shared.mainContext)
        CoreDataStack.shared.mainContext.saveChanges()
    }
    
    // update Method
    func updateMovie(with: Movie, title: String, hasWatched: Bool) {
        
        
    }
    
    //delete Method
    func deleteMovie(_ movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        CoreDataStack.shared.mainContext.saveChanges()
    }
    
}

// MARK: - extension for the json encoding method.
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

// MARK: - extension for the movie Database fetchRequest.
extension MovieController {
    func addMovieToDataBase(movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        
        let identifier = movie.identifier ?? UUID().uuidString
        let requestURL = dataBaseUrl.appendingPathComponent(identifier).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movie.movieRepresentation)
        } catch {
            NSLog("Error encoding Movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting Entry to server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            }.resume()
    }
    
    func getMoviesFromDataBase(completion: @escaping ((Error?) -> Void) = { _ in }) {
        
        let requestURL = dataBaseUrl.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching movie from server: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            var movies: [MovieRepresentation] = []
            
            do {
                movies = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({$0.value})
                self.updateMovies(with: movies)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            }.resume()
        
    }
    
    private func updateMovies(with representations: [MovieRepresentation]) {
        
        let moviesWithID = representations.filter({ $0.identifier != nil })
        let identifiersToFetch = moviesWithID.compactMap({UUID(uuidString: $0.identifier!)})
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
        
        var entriesToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.persistenContainer.newBackgroundContext()
        
        context.performAndWait {
            
            do {
                let movies = try context.fetch(fetchRequest)
                
                for movie in movies {
                    guard let id = movie.identifier,
                        let identifier = UUID(uuidString: id),
                        let representation = representationsByID[identifier] else { continue }
                    self.update(entry: entry, with: representation)
                    //  entriesToCreate.removeValue(forKey: identifier)
                }
                
                for representation in entriesToCreate.values {
                    Entry(entryRepresentation: representation, context: context)
                }
                
            } catch {
                NSLog("Error fetching tasks for UUIDs: \(error)")
            }
            
            CoreDataStack.shared.mainContext.save()
        }
    }
    

}
