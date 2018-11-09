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
    
    func saveToPersistenceStore() {
        let moc = CoreDataStack.shared.mainContext
        do {
            try moc.save()
        } catch {
            NSLog("Could not save to disk: \(error)")
        }
    }
    
    func loadFromPersistentStore() -> [Movie] {
        let moc = CoreDataStack.shared.mainContext
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        do {
            return try moc.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
            return []
        }
    }
    
    func newMovie(title: String, hasWatched: Bool) -> Movie{
        let movie = Movie(title: title, hasWatched: hasWatched)
        
        saveToPersistenceStore()
        // PUT TO SERVER
        
        return movie
    }
    
    func stubToMovie(stub: MovieRepresentation) -> Movie{
        if stub.hasWatched == nil {
            return newMovie(title: stub.title, hasWatched: false)
        } else {
            return newMovie(title: stub.title, hasWatched: stub.hasWatched!)
        }
    }
    
    func fetchOneMovie(identifier: UUID) -> Movie? {
        let moc = CoreDataStack.shared.mainContext
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier.uuidString)
        
        do {
            return try moc.fetch(fetchRequest)[0]
        } catch {
            NSLog("Error fetching tasks: \(error)")
            return nil
        }
    }
    
    func matchStubToMovie(movie: Movie, stub: MovieRepresentation) {
        movie.title = stub.title
        movie.identifier = stub.identifier
        movie.hasWatched = stub.hasWatched ?? false
        
    }
    
    func updateMovie(movie: Movie, title: String, hasWatched: Bool) {
        movie.setValue(title, forKey: "title")
        movie.setValue(hasWatched, forKey: "hasWatched")
        
        saveToPersistenceStore()
        // PUT TO SERVER
    }
    
    func deleteMovie(movie: Movie) {
        let moc = CoreDataStack.shared.mainContext
        moc.delete(movie)
        saveToPersistenceStore()
    }
    
    
}
