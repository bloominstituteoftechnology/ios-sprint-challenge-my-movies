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
    
    // MARK: - INIT
    
    init() {
        fetchFromServer()
    }
    
    // MARK: - API Methods
    
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
    
    // MARK: - DB Methods
    
    func put(movie: Movie, completion: @escaping (Error?) -> Void = {_ in}) {
        
        let requestURL = databaseURL?.appendingPathComponent(movie.identifier?.uuidString ?? UUID().uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL!)
        request.httpMethod = HTTPMethod.put.rawValue
        
        do { request.httpBody = try JSONEncoder().encode(movie)}
        catch{
            NSLog("Error Encoding Data: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                NSLog("Error PUTing entry: \(error)")
                completion(error)
                return
            }
            print(response ?? "PUT successful")
            completion(nil)
            
            }.resume()
        
    }
    
    func movie(for identifier: String, in context: NSManagedObjectContext) -> Movie? {
        
        guard let identifier = UUID(uuidString: identifier) else {return nil}
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "identifier == %@", identifier as NSUUID)
        fetchRequest.predicate = predicate
        
        var result: Movie? = nil
        context.performAndWait {
            
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching task with UUID")
                return
            }
        }
        return result
    }
    
    
    func fetchFromServer(completion: @escaping (Error?) -> Void = {_ in}) {
        
        let requestURL = databaseURL!.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("error fetching tasks")
                completion(error)
                return
            }
            guard let data = data else {
                NSLog("No data returned from FETCH")
                completion(NSError())
                return
            }
            do{
                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                
                let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
                
                backgroundContext.performAndWait {
                    
                    for movieRep in movieRepresentations{
                        
                        let _ = Movie(movieRep: movieRep, context: backgroundContext)
                        
                    }
                }
                
                do {
                    try CoreDataStack.shared.save(context: backgroundContext)
                } catch {
                    NSLog("Error saving background context: \(error)")
                }
            }catch{
                NSLog("error decoding: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
        
        
    }


// MARK: -- Local Methods

func addMovie(title: String, hasWatched: Bool = false, identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
    
    let movie = Movie(title: title, hasWatched: hasWatched, identifier: identifier, context: context)
    
    do {
        try CoreDataStack.shared.save(context: context)
    } catch {
        NSLog("Error saving task: \(error)")
    }
    put(movie: movie)
}



// MARK: - Properties
let databaseURL = URL(string: "https://mymovies-table.firebaseio.com/")
var searchedMovies: [MovieRepresentation] = []
}

