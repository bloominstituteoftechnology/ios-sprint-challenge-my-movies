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
    private let firebaseBaseURL = URL(string: "https://coredata-283af.firebaseio.com/")!
    
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
    
    // MARK: - CRUD
    
    func put(movie: Movie, completion: @escaping ((Error?) -> Void) =  { _ in }) {
        guard let identifier = movie.identifier else {
            return print("No ID in PUT request")
        }
        
        let url = firebaseBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        
        do {
//            guard let movie = movie.movieRepresentation else {
//                return completion(NSError())
//            }
            
            urlRequest.httpBody = try JSONEncoder().encode(movie)
        } catch {
            NSLog("Error encoding entry: \(error.localizedDescription)")
            return completion(error)
        }
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTTING data to server: \(error.localizedDescription)")
                return completion(nil)
            }
            completion(nil)
            } .resume()
    }
    
    func create(movieRep: MovieRepresentation) {
        let moc = CoreDataStack.shared.container.newBackgroundContext()

        moc.performAndWait {
            guard let movie = Movie(movieRepresentation: movieRep, context: moc) else {return}
            
            do {
                try CoreDataStack.shared.save(context: moc)
            } catch {
                return print("Error creating moc.")
            }
            self.put(movie: movie)
        }
    }
    
    func delete(movie: Movie) {
        let moc = CoreDataStack.shared.mainContext
        deleteMovieFromServer(movie: movie)

        moc.perform {
            do {
                moc.delete(movie)
                try CoreDataStack.shared.save(context: moc)
            } catch let deleteError {
                NSLog("Error deleting moc: \(deleteError)")
                return
            }
        }
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping (Error?) -> Void = { _ in }){
        guard let identifier = movie.identifier else {return}
        
        let url = firebaseBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                NSLog("Error sending deletion request to server: \(error.localizedDescription)")
                return completion(error)
            }
            completion(nil)
            }.resume()
    }
    
    func fetchMovieFromCoreData(identifier: UUID, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier.uuidString)
        
        var result: Movie? = nil

        do {
            result = try context.fetch(fetchRequest).first
            return result
        }
        catch {
            print("Error fetching movie: \(error.localizedDescription)")
        }
        return result
    }
    
    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        let url = firebaseBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return completion(error)
            }
            guard let data = data else {
                return completion(NSError())
            }
            
            do {
                let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
                
                let movieData = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
                let myMovieRep = Array(movieData.values)
                
                try self.updateMovies(movieRepresentations: myMovieRep, context: backgroundContext)
                try CoreDataStack.shared.save(context: backgroundContext)
                completion(nil)
            }
            catch {
                return completion(error)
            }}.resume()
    }
    
    func update(movie: Movie, representation: MovieRepresentation) {
        movie.title = representation.title
        movie.identifier = representation.identifier
        
        guard let hasWatched = representation.hasWatched else {return} // may be nil
        movie.hasWatched = hasWatched
    }
    
    func updateMovies(movieRepresentations: [MovieRepresentation], context: NSManagedObjectContext) throws {
        context.performAndWait {
            for movieRep in movieRepresentations {
                guard let identifier = movieRep.identifier else { continue }
                
                if let movie = self.fetchMovieFromCoreData(identifier: identifier, context: context) {
                    self.update(movie: movie, representation: movieRep)
                } else {
                    let _ = Movie(movieRepresentation: movieRep, context: context)
                }
            }
        }
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
