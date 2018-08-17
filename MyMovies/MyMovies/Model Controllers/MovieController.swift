//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MovieController
{
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []

    init()
    {
        fetchMoviesFromDatabase()
    }
    
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
                print(self.searchedMovies.count)
                completion(nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    private let firebaseURL = URL(string: "https://journal-e4408.firebaseio.com/")!
    
    func uploadToDatabase(with movie: Movie, completion: @escaping (Error?) -> () = {_ in })
    {
        let url = firebaseURL.appendingPathComponent(movie.identifier!).appendingPathExtension("json")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        
        do {
            let data = try JSONEncoder().encode(movie)
            urlRequest.httpBody = data
        } catch {
            NSLog("Failed to encode movie object: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            
            if let error = error
            {
                NSLog("Error uploading to database: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    func deleteMovieFromDatabase(movie: Movie, completion: @escaping (Error?) -> () = {_ in })
    {
        let url = firebaseURL.appendingPathComponent(movie.identifier!).appendingPathExtension("json")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            
            if let error = error
            {
                NSLog("Failed to delete from server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func fetchSingleMovieFromPersistence(identifier: String, context: NSManagedObjectContext) -> Movie?
    {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        do {
            let moc = CoreDataStack.shared.mainContext
            return try moc.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching movie: \(error)")
            return nil
        }
    }
    
    func fetchMoviesFromDatabase(completion: @escaping (Error?) -> () = {_ in })
    {
        let url = firebaseURL.appendingPathExtension("json")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            
            if let error = error
            {
                NSLog("Error fetching from server: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("Failed to unwrap data")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                let backgroundMoc = CoreDataStack.shared.container.newBackgroundContext()
                try self.updateMovies(with: movieRepresentations, context: backgroundMoc)
                completion(nil)
                
            } catch {
                NSLog("Error decoding data: \(error)")
                completion(error)
                return
            }
            }.resume()
    }
    
    private func updateMovies(with representations: [MovieRepresentation], context: NSManagedObjectContext) throws
    {
        var error: Error?
        
        context.performAndWait {
            
            for movieRep in representations
            {
                let movie = self.fetchSingleMovieFromPersistence(identifier: (movieRep.identifier?.uuidString)!, context: context)
                
                if let movie = movie
                {
                    if movie != movieRep
                    {
                        self.update(movie: movie, movieRepresentation: movieRep)
                    }
                }
                else
                {
                    let _ = Movie(movieRepresentation: movieRep)
                }
            }
            
            do {
                try CoreDataStack.shared.saveContext()
            } catch let saveError {
                error = saveError
            }
        }
        
        if let error = error { throw error }
        
    }
    
    func update(movie: Movie, movieRepresentation: MovieRepresentation)
    {
        movie.title = movieRepresentation.title
        movie.hasWatched = movieRepresentation.hasWatched!
        movie.identifier = movieRepresentation.identifier?.uuidString
    }
    
    func deleteMovie(on movie: Movie)
    {
        deleteMovieFromDatabase(movie: movie)
        CoreDataStack.shared.mainContext.delete(movie)
        
        do {
            try CoreDataStack.shared.saveContext()
        } catch {
            NSLog("Error saving update: \(error)")
        }
    }
    
    func updateHasWatched(on movie: Movie, with status: Bool)
    {
        let backgroundMoc = CoreDataStack.shared.container.newBackgroundContext()
        
        backgroundMoc.performAndWait {
            movie.hasWatched = status
        }
        
        do {
            try CoreDataStack.shared.saveContext()
            self.uploadToDatabase(with: movie)
        } catch {
            NSLog("Error updating hasWatched status on persistence: \(error)")
            return
        }
    }
}












