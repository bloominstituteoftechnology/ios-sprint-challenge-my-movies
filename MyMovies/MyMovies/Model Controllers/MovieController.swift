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
    typealias CompletionHandler = (Error?) -> Void
    var movies: [Movie] = []
    
    init()
    {
        fetchMovieFromServer()
    }
    
    func createMovie(title: String)
    {
        let movie = Movie(title: title)
        movies.append(movie)
        print(movie)
       put(movie: movie)
        
    }
    
    
    
    // MARK: - Update
    
    private func updateMovies(with representations: [MovieRepresentation], context: NSManagedObjectContext) throws
    {
        var error: Error?
        
        context.performAndWait {
            
            for movieRep in representations
            {
                guard let uuid = movieRep.identifier else { continue }
                let movie = self.movie(forUUID: uuid, in: context)
                
                if let movie = movie
                {
                    self.update(movie: movie, with: movieRep)
                }
                else
                {
                    let _ = Movie(movieRepresentation: movieRep, context: context)
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
    
    private func update(movie: Movie, with representation: MovieRepresentation)
    {
        movie.title = representation.title
        movie.identifier = representation.identifier
        movie.hasWatched = representation.hasWatched!
    }
    
    private func movie(forUUID uuid: UUID, in context: NSManagedObjectContext) -> Movie?
    {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        
        do{
            
            return try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching task with uuid \(error)")
            return nil
        }
    }
    
    
    
    // MARK: - Firebase
    
    private let firebaseBaseURL = URL(string: "https://mymovies-dee4d.firebaseio.com/")!
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _  in })
    {
        let uuid = movie.identifier ?? UUID()
        let requestURL = firebaseBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        print(requestURL)
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"//to update existing movie
        
        do
        {
            guard var representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            
            representation.identifier = uuid
            movie.identifier = uuid
            
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding movie \(movie): \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTing task to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    func fetchMovieFromServer(completion: @escaping CompletionHandler = { _ in })
    {
        let requestURL = firebaseBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
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
                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                let backgroundMoc = CoreDataStack.shared.container.newBackgroundContext()
                
                try self.updateMovies(with: movieRepresentations, context: backgroundMoc)
                
                completion(nil)
                
            }
            catch
            {
                NSLog("Error decoding task representations: \(error)")
                completion(error)
                return
            }
            
            }.resume()
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = firebaseBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(response!)
            completion(error)
        }.resume()
    }
    
    // MARK: - Search
    
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
}
