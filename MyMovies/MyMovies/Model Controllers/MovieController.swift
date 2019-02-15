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
    
    init() {
        fetchMoviesFromServer()
    }
    
    let moc = CoreDataStack.shared.mainContext
    let backgroundMoc = CoreDataStack.shared.backgroundContext
    
    private let fireBaseURL = URL(string: "https://journalcoredata-angel.firebaseio.com/")!
    
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
    
    
    // MARK: - CRUD FUNCTIONS
    
    func putToServer(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        let identifier = movie.identifier ?? UUID()
        
        let urlPlusID = fireBaseURL.appendingPathComponent(identifier.uuidString)
        let urlPlusJSON = urlPlusID.appendingPathExtension("json")
        
        var request = URLRequest(url: urlPlusJSON)
        request.httpMethod = "PUT"
        
        do {
            let encoder = JSONEncoder()
            let movieJSON = try encoder.encode(movie)
            request.httpBody = movieJSON
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error putting movie to the server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            }.resume()
    }
    
    func deleteFromServer(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        guard let identifier = movie.identifier else { return }
        
        let urlPlusID = fireBaseURL.appendingPathComponent(identifier.uuidString)
        let urlPlusJSON = urlPlusID.appendingPathExtension("json")
        
        var request = URLRequest(url: urlPlusJSON)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting movie from server: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    func fetchSingleMovieFromPersistentStore(identifier: String, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        
        var movie: Movie?
        context.performAndWait {
            do {
                movie = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching single movie from Persistent Store")
            }
        }
        return movie
    }
    
    func updatePersistentStoreWithServer(_ movieRepresentations: [MovieRepresentation],
                                         context: NSManagedObjectContext) {
        context.performAndWait {
            for mr in movieRepresentations {
                let movie = self.fetchSingleMovieFromPersistentStore(identifier: (mr.identifier?.uuidString)!,
                                                                     context: context)
                
                if let movie = movie, movie != mr {
                    self.update(movie: movie, movieRep: mr)
                } else if movie == nil {
                    _ = Movie(movieRep: mr, context: context)
                }
            }
        }
    }
    
    func update(movie: Movie, movieRep: MovieRepresentation) {
        movie.title = movieRep.title
        movie.hasWatched = movieRep.hasWatched ?? false
        movie.identifier = movieRep.identifier
        
        putToServer(movie: movie)
        saveToPersistentStore()
    }
    
    func createMovie(with title: String, identifier: UUID?, hasWatched: Bool?){
        
        guard let identifier = identifier, let hasWatched = hasWatched else {
            
            let movie = Movie(title: title, identifier: UUID(), hasWatched: false)
            putToServer(movie: movie)
            saveToPersistentStore()
            return
        }
        let movie = Movie(title: title, identifier: identifier, hasWatched: hasWatched)
        
        putToServer(movie: movie)
        saveToPersistentStore()
    }
    
    func saveToPersistentStore() {
        moc.performAndWait {
            do {
                try moc.save()
            } catch {
                moc.reset()
                NSLog("Error saving managed object context: \(error)")
            }
        }
        
    }
    
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        let urlPlusJSON = fireBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: urlPlusJSON) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movies from server: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else  {
                NSLog("No data returned from server")
                completion(NSError())
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let movieRepDict = try decoder.decode([String: MovieRepresentation].self, from: data)
                let movieRepresentations = movieRepDict.map{ $0.value }
                
                self.updatePersistentStoreWithServer(movieRepresentations, context: self.backgroundMoc)
                self.saveToBackgroundMoc()
                completion(nil)
            } catch {
                NSLog("Error decoding movie representation: \(error)")
                completion(error)
            }
            
            }.resume()
    }
    
    func saveToBackgroundMoc() {
        self.backgroundMoc.performAndWait {
            do {
                try self.backgroundMoc.save()
            } catch {
                NSLog("Error saving background context: \(error)")
            }
        }
    }
    
   
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
