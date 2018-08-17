//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData


private let fireBaseURL = URL(string: "https://sprint4challenge.firebaseio.com/")!
private let moc = CoreDataStack.shared.mainContext

class MovieController {
    
    // MARK: - Networking with Movie DB
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
    // MARK: - Networking with Firebase
    typealias CompletionHandler = (Error?) -> Void
    
    func put(movie: Movie, completion: @escaping CompletionHandler = {_ in}){
        let url = fireBaseURL
            .appendingPathComponent(movie.identifier!.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        do {
            let movieRepresentation = MovieRepresentation(ofMovie: movie)
            let data = try JSONEncoder().encode(movieRepresentation)
            request.httpBody = data
        } catch {
            NSLog("Error encoding:\(error)")
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error sending data to firebase: \(error)")
                completion(error)
            }
            completion(nil)
            }.resume()
        
    }
    
    func deleteFromServer(movie: Movie, completion: @escaping CompletionHandler = {_ in}){
        let url = fireBaseURL
            .appendingPathComponent(movie.identifier!.uuidString)
            .appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error{
                NSLog("Error deleting: \(error)")
                completion(error)
            }
            completion(nil)
            }.resume()
        
    }
    //MARK: - Local Persistence Methods
    func saveToPersistentStore(context: NSManagedObjectContext = moc){
        do{
            try context.save()
        }catch{
            NSLog("Error saving: \(error)")
            moc.reset()
            return
        }
    }
    
    
    // MARK: - CRUD Methods
    func createAndSave(movieRepresentation: MovieRepresentation){
        let movie = Movie(title: movieRepresentation.title)
        
        put(movie: movie) { (error) in
            moc.perform {
                if let error = error {
                    NSLog("Error putting movie: \(error)")
                    moc.reset()
                    return
                }
                
                do{
                    try moc.save()
                }catch{
                    NSLog("Error saving Movie: \(error)")
                    moc.reset()
                    return
                }
            }
        }
    }
    
    func deleteAndSave(movie:Movie){
        moc.delete(movie)
        deleteFromServer(movie: movie) { (error) in
            if let error = error {
                NSLog("Error deleting from server: \(error)")
                return
            }
        }
        do{
            try moc.save()
        }catch{
            NSLog("Error saving Movie: \(error)")
            moc.reset()
            return
        }
    }
    
    func updateAndSave(movie:Movie){
        movie.hasWatched = !movie.hasWatched
        put(movie: movie) { (error) in
            moc.perform {
                if let error = error {
                    NSLog("Error: \(error)")
                    moc.reset()
                    return
                }
                do{
                    try moc.save()
                } catch {
                    NSLog("Error saving changes: \(error)")
                    moc.reset()
                    return
                }
            }
        }
    }
    
    
    func fetchSingleMovieFromPersistentStore(identifier: String) ->Movie?{
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", identifier)
        var movie: Movie?
        moc.performAndWait {
            
            do{
                movie = try moc.fetch(request).first
            } catch {
                NSLog("Error fetching from persistent store: \(error)")
                
            }
        }
        return movie
    }
    
    
    func fetchMoviesFromServers(completion: @escaping CompletionHandler = {_ in}){
        let url = fireBaseURL.appendingPathExtension("json")
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error{
                NSLog("Error GETting: \(error)")
                return
            }
            guard let data = data else {return}
            do{
                let decoded = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
                let movieRepresentations = Array(decoded.values)
                let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
                
                backgroundContext.performAndWait{
                    for movieRepresentation in movieRepresentations{
                        let movie = self.fetchSingleMovieFromPersistentStore(identifier: movieRepresentation.identifier!.uuidString)
                        
                        //there is a duplicate or it needs to be updated
                        if let movie = movie {
                            if movie != movieRepresentation{
                                self.updateAndSave(movie: movie)
                            }
                        } else {
                            _ = Movie(movieRepresentation: movieRepresentation, context: backgroundContext)
                        }
                    }
                    self.saveToPersistentStore(context:backgroundContext)
                }
                completion(nil)
            } catch {
                NSLog("Error decoding: \(error)")
                return
            }
            }.resume()
        
    }
    
    
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
