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
    
    init(){
        fetchMovieFromServer()
    }
    
    typealias CompletionHandler = (Error?)->Void
    
    
    
    
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
    
    static let baseURL = URL(string: "https://mymovies-c9e77.firebaseio.com/")!
    
    func put(movie: Movie, completion: @escaping CompletionHandler = {_ in }) {
        
        let identifier = movie.identifier ?? UUID()
        let requestURL = MovieController.baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movie)
        }catch {
            NSLog("Error encoding task:\(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) {(data, _, error) in
            if let error = error {
                NSLog("Error PUTing task to server:\(error)")
                completion(error)
                return
            }
            completion(nil)
            } .resume()
        
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = {_ in}) {
        
        guard let identifier = movie.identifier else {
            NSLog("no identifier for deletion")
            completion(NSError())
            return
        }
        let requestURL =
            MovieController.baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request)  {(data, _, error) in
            if let error = error {
                NSLog("Error DELETing task to server:\(error)")
                completion(error)
                return
            }
            
            } .resume()
        
    }
    
    
    func create(title: String, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        
        let movie = Movie(title: title, context: context)
        do {
            try CoreDataStack.shared.save(context:context)
        } catch {
            NSLog("error creating movie:\(error)")
            
        }
        put(movie: movie)
        
    }
    
    func Update(movie: Movie, hasWatched: Bool){
        
        movie.hasWatched = hasWatched
        put(movie: movie)
        
    }
    
    
    func delete(movie: Movie){
        
        let moc = CoreDataStack.shared.mainContext
        deleteMovieFromServer(movie: movie)
        moc.delete(movie)
        
        do {
            try CoreDataStack.shared.save(context: moc)
        }catch {
            moc.reset()
            NSLog("error deleting:\(error)")
        }
    }
    
    
    func fetchSingleMovieFromPersistentStore(identifier: String, context: NSManagedObjectContext) -> Movie? {
        guard let identifier = UUID(uuidString: identifier) else {return nil}
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        let predicate = NSPredicate(format: "identifier == %@", identifier as NSUUID)
        
        fetchRequest.predicate = predicate
        
        var movies: Movie? = nil
        context.performAndWait {
            
            do {
                movies = try context.fetch(fetchRequest).first
                
            }catch {
                NSLog("Error fetching task with identifier:\(error)")
                
            }
        }
        return movies
    }
    
    
    
    
    private func update(movie: Movie, movieRepresentation: MovieRepresentation) {
        movie.title = movieRepresentation.title
        movie.hasWatched = movieRepresentation.hasWatched ?? false
        movie.identifier = movieRepresentation.identifier
    }
    
    
    
    
    
    
    func fetchMovieFromServer(completion: @escaping CompletionHandler = {_ in }) {
        let requestURL = MovieController.baseURL.appendingPathExtension("json")
        URLSession.shared.dataTask(with: requestURL) {(data, _, error) in
            if let error = error {
                NSLog("Error fetching:\(error)")
                completion(NSError())
                return
            }
            guard let data = data else {
                NSLog("no data returned")
                completion(NSError())
                return
            }
            
            let moc = CoreDataStack.shared.container.newBackgroundContext()
            
            do {
                let movieRepres = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({ $0.value })
               // let moc = CoreDataStack.shared.container.newBackgroundContext()
                
                moc.performAndWait {
                    
                    for mRep in movieRepres {
                        guard let identifier = mRep.identifier?.uuidString else { return }
                        if let movie = self.fetchSingleMovieFromPersistentStore(identifier: identifier, context: moc) {
                            self.update(movie: movie, movieRepresentation: mRep)
                        } else {
                            let _ = Movie(movieRepresentation: mRep, context: moc)
                        }
                    }
                moc.perform {
                    try! moc.save()
                    }
                    do {
                        try CoreDataStack.shared.save(context: moc)
                    } catch {
                        NSLog("Error saving background context: \(error)")
                    }
                }
                
                completion(nil)
                
            } catch {
                NSLog("Error decoding data: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
        
    }
    
}

