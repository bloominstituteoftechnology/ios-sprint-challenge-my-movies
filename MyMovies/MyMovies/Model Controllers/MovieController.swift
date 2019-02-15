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
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    // MARK: - CORE DATA MOVIE IMPLEMENTATION
    
    private let firebaseURL = URL(string: "https://my-movies-f2248.firebaseio.com/")!
    let moc = CoreDataStack.shared.mainContext
    let backgroundMoc = CoreDataStack.shared.backgroundContext
    
    // MARK: - Persistent Coordinator
    
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
    
    func saveToBackgroundMoc() {
        self.backgroundMoc.performAndWait {
            do {
                try self.backgroundMoc.save()
            } catch {
                NSLog("Error saving background context: \(error)")
            }
        }
    }
    
    
    func addMovie(withTitle title: String) {
        let movie = Movie(title: title, hasWatched: false)
        
        put(movie: movie)
        saveToPersistentStore()
    }
    
    func updateMovie(withMovie movie: Movie, andToggle hasWatched: Bool) {
        
        movie.hasWatched = hasWatched
        
        put(movie: movie)
        saveToPersistentStore()
    }
    
    func delete(withMovie movie: Movie) {
        moc.delete(movie)
        
        deleteFromServer(movie: movie)
        saveToPersistentStore()
    }
    
    func put(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        
        let identifier = movie.identifier ?? UUID()
        
        let url = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        do {
            let encoder = JSONEncoder()
            let movieJSON = try encoder.encode(movie)
            request.httpBody = movieJSON
        } catch {
            NSLog("Error encoding error: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error putting entry tot the server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
            }.resume()
    }
    
    func deleteFromServer(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let identifier = movie.identifier else { return }
        
        let url = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting entry from server: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    func updateFetch(movie: Movie, movieRep: MovieRepresentation) {
        
        movie.identifier = movieRep.identifier
        movie.title = movieRep.title
        movie.hasWatched = movieRep.hasWatched ?? false
        
    }
    
    func fetchSingleEntryFromPersistentStore(identifier: String, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        
        var movie: Movie?
        context.performAndWait {
            do {
                movie = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching single entry from Persistent Store")
            }
        }
        return movie
    }
    
    func updatePersistentStore(_ movieRepresentations: [MovieRepresentation],
                                         context: NSManagedObjectContext) {
        context.performAndWait {
            for mr in movieRepresentations {
                let movie = self.fetchSingleEntryFromPersistentStore(identifier: (mr.identifier?.uuidString)!,
                            context: context)
                
                if let movie = movie, movie != mr {
                    self.updateFetch(movie: movie, movieRep: mr)
                } else if movie == nil {
                    Movie(movieRep: mr, context: context)
                }
            }
        }
    }
   
    
    func fetchEntriesFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        let urlPlusJSON = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: urlPlusJSON) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching entries from server: \(error)")
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
                
                self.updatePersistentStore(movieRepresentations, context: self.backgroundMoc)
                self.saveToBackgroundMoc()
                completion(nil)
            } catch {
                NSLog("Error decoding entry representation: \(error)")
                completion(error)
            }
            
            }.resume()
    }
    
}
