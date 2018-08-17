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
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseBaseURL = URL(string:"https://mymovies-b8436.firebaseio.com/")
    
    typealias CompletionHandler = (Error?) -> Void
    
    var movie: Movie?
    
    init()
    {
        fetchEntriesFromServer()
    }
    
    func saveToPersistentStore() throws
    {
        let moc = CoreDataStack.shared.mainContext
        try moc.save()
    }
    
    func createMovie(title: String, identifier: String, hasWatched: Bool)
    {
        let movie = Movie(title: title, identifier: identifier, hasWatched: hasWatched)
        print("Let's see what we've got here: \(title), \(identifier)")
        //saveToPersistentStore()
        put(movie: movie)
    }
    
    func updateMovie(movie: Movie, title: String, identifier: String, hasWatched: Bool)
    {
        let movie = movie
        movie.title = title
        movie.identifier = identifier
        movie.hasWatched = hasWatched
        print(title, identifier)
        //saveToPersistentStore()
        put(movie: movie)
    }
    
    func deleteMovie(movie: Movie)
    {
        let movie = movie
        let moc = CoreDataStack.shared.mainContext
        moc.delete(movie)
        deleteMovieFromServer(movie: movie)
        do
        {
            try moc.save()
        }
        catch
        {
            moc.reset()
        }
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in })
    {
        let requestURL = baseURL.appendingPathComponent(movie.identifier!).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTing movie to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }
            .resume()
    }
    
    func put(movie:Movie, completion: @escaping CompletionHandler = { _ in })
    {
        let requestURL = baseURL.appendingPathComponent(movie.identifier!).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"//to update existing task
        
        do {
            request.httpBody = try JSONEncoder().encode(movie)
        } catch {
            NSLog("Error encoding movie \(movie): \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTing movie to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }
        .resume()
    }
    
    private func update(movie: Movie, with representation: MovieRepresentation)
    {
        movie.title = representation.title
        movie.identifier = representation.identifier
        movie.hasWatched = representation.hasWatched!
    }
    
    func fetchSingleMovieFromPersistentStore(identifier: String, context: NSManagedObjectContext) -> Movie?
    {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        var result: Movie? = nil
        do
        {
            result = try context.fetch(fetchRequest).first
        }
        catch
        {
            NSLog("Error fetching task with identifier \(error)")
            return nil
        }
        return result
    }
    
    func fetchEntriesFromServer(completion: @escaping CompletionHandler = { _ in })
    {
        let requestURL = firebaseBaseURL?.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL!) { (data, _, error) in
            if let error = error
            {
                NSLog("Error fetching tasks: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else
            {
                NSLog("No data returned by data task")
                completion(error)
                return
            }
            
            do
            {
                let movieReps = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                let backgroundMoc = CoreDataStack.shared.container.newBackgroundContext()
                
                try self.updateMovies(with: movieReps, context: backgroundMoc)
                
                completion(nil)
            }
            catch
            {
                NSLog("Error decoding entry representations: \(error)")
                completion(error)
                return
            }
            }.resume()
    }
    
    private func updateMovies(with representations: [MovieRepresentation], context: NSManagedObjectContext) throws
    {
        var error: Error?
        
        context.performAndWait {
            
            for movieRep in representations {
                
                guard let movie = self.fetchSingleMovieFromPersistentStore(identifier: movieRep.identifier!, context: context) else {
                    let _ = Movie(movieRepresentation: movieRep, context: context)
                    continue
                    
                }
                
                if movie == movie
                {
                    self.update(movie: movie, with: movieRep)
                }
                
            }
            
            do
            {
                try context.save()
            }
            catch let saveError
            {
                error = saveError
            }
        }
        if let error = error {throw error}
    }
    
    // MARK: - Search
    
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void)
    {
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(NSError())
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error
            {
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
}
