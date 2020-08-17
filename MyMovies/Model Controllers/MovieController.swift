//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum NetworkError: Error {
    case otherError
    case noData
    case failedDecode
    case noIdentifier
    case noDecode
}

class MovieController {
    
    //add firebaseURL.. didnt know how to do that
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    //add url for updating movies
    private let firebaseURL = URL(string: "String")!
    
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    // MARK: - Properties
    
    var searchedMovies: [MovieDBMovie] = []
    
    // MARK: - TheMovieDB API
    
    func searchForMovie(with searchTerm: String, completion: @escaping CompletionHandler) {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(.failure(.otherError))
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error searching for movie with search term \(searchTerm): \(error)")
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(.failure(.noData))
                return
            }
            
            do {
                let movieDBMovies = try JSONDecoder().decode(MovieDBResults.self, from: data).results
                self.searchedMovies = movieDBMovies
                completion(.success(true))
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(.failure(.failedDecode))
            }
        }.resume()
    }
    
    init() {
        fetchMoviesFromServer()
    }
    
    //fetch movies
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        let task = URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error \(error)")
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                print("No data returned")
                completion(.failure(.noData))
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                try self.updateMovies(with: movieRepresentations)
                completion(.success(true))
            } catch {
                print("Error \(error)")
                completion(.failure(.noDecode))
                return
            }
            
        }
        task.resume()
    }
    
    //Delete Movies
    func deleteMoviesFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            print(response!)
            completion(.success(true))
        }
        task.resume()
    }
    
    func sendMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = "PUT"
        
        do {
            guard let representation = movie.movieRep else {
                completion(.failure(.otherError))
                return
            }
            
            request.httpBody = try JSONEncoder().encode(representation)
            
        } catch {
            print("Error encoding movie \(movie): \(error)")
            completion(.failure(.otherError))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (_, _, error) in //normally has data, request, error
            if let error = error {
                print("Error \(error)")
                completion(.failure(.otherError))
                return
            }
            
            completion(.success(true))
            
        }
        
        task.resume()
    }
    
    //Updating movies
    private func updateMovies(with representations: [MovieRepresentation]) throws {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        let identifiersToFetch = representations.compactMap({UUID(uuidString: $0.identifier)})
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        
        var moviesToAdd = representationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
            
            //NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier in %@", identifiersToFetch)
        
        
        context.performAndWait {
            
            do {
                let existingMovies = try context.fetch(fetchRequest)
                
                //update existing
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else {
                            continue }
                    //We already have the task, so wer should update
                    movie.title = representation.title
                    movie.hasWatched = representation.hasWatched
                    
                    moviesToAdd.removeValue(forKey: id)
                }
                
                //new movie
                for representation in moviesToAdd.values {
                    Movie(movieRep: representation, context: context)
                }
                
            } catch {
                print("Error fetching tasks for UUIDs: \(error)")
            }
        }
        
        try CoreDataStack.shared.save(context: context)
        
    }
    
}



/* fetch and delete
 
 //fetch tasks
 func fetchTasksFromServer(completion: @escaping CompletionHandler = { _ in }) {
 let requestURL = baseURL.appendingPathExtension("json")
 
 let task = URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
 if let error = error {
 print("Error \(error)")
 completion(.failure(.otherError))
 return
 }
 
 guard let data = data else {
 print("No data returned")
 completion(.failure(.noData))
 return
 }
 
 do {
 let taskRepresentations = Array(try JSONDecoder().decode([String: TaskRepresentation].self, from: data).values)
 try self.updateTasks(with: taskRepresentations)
 completion(.success(true))
 } catch {
 print("Error \(error)")
 completion(.failure(.noDecode))
 return
 }
 
 }
 task.resume()
 }
 
 //Delete Task
 func deleteTaskFromServer(_ task: Task, completion: @escaping CompletionHandler = { _ in }) {
 guard let uuid = task.identifier else {
 completion(.failure(.noIdentifier))
 return
 }
 
 let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
 var request = URLRequest(url: requestURL)
 request.httpMethod = "DELETE"
 
 let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
 print(response!)
 completion(.success(true))
 }
 task.resume()
 }
 */
