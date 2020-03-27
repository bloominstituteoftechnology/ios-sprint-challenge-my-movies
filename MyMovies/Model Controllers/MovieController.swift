//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

class MovieController {
    
    init() {
        fetchMoviesFromServer()
    }
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    //private let myURL =
    typealias CompletionHandler = (Error?) -> Void
    
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
    
    // myMovie
    
    private let myURL = URL(string: "https://mymovie-49b06.firebaseio.com/")!
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let identifier = movie.identifier ?? UUID()
        let requestURL = myURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        let jsonEncoder = JSONEncoder()
        do {
            guard var representation = movie.movieRepresentation else {
                NSLog("No rep.")
                return
            }
            representation.identifier = identifier
            try CoreDataStack.shared.mainContext.save()
            request.httpBody = try jsonEncoder.encode(representation)
        } catch {
            NSLog("encoding error")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response , error ) in
            
            guard error == nil else {
                NSLog("put error")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            if let response = response {
                NSLog("\(response)")
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    func fetchMoviesFromServer(completion: @escaping (Error?) -> () = { _ in }) {
        let requesURL = myURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requesURL) { (data, _, error) in
            guard error == nil else {
                NSLog("fetch error")
                DispatchQueue.main.async {
                    completion(NSError())
                }
                return
            }
            guard let data = data else {
                NSLog("no fetch data")
                DispatchQueue.main.async {
                    completion(NSError())
                }
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do {
                let representations = try jsonDecoder.decode([String: MovieRepresentation].self, from: data)
                let representationsValueArray = Array(representations.values)
                self.updateMovies(with: representationsValueArray)
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                NSLog("decode error")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
        }.resume()
    }
    
    func updateMovies(with representation: [MovieRepresentation]) {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let hasID = representation.map { $0.identifier }
        var sortedByID = Dictionary(uniqueKeysWithValues: zip(hasID, representation))
        
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", sortedByID)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.performAndWait {
            do {
                let exist = try context.fetch(fetchRequest)
                for movie in exist {
                    guard let identifier = movie.identifier,
                        let representation = sortedByID[identifier] else {return}
                    update(movie: movie, with: representation)
                    sortedByID.removeValue(forKey: identifier)
                }
                
                for notExist in sortedByID.values {
                    Movie(movieRepresentation: notExist, context: context)
                }
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("sync error")
            }
        }
    }
    
    func update(movie: Movie, with representation: MovieRepresentation) {
        guard let hasWatched = representation.hasWatched else { return }
        movie.title = representation.title
        movie.hasWatched = hasWatched
        movie.identifier = representation.identifier
    }
    
    
    func updateMovies(movie: Movie, title: String, hasWatched: Bool, identifier: UUID) {
        movie.title = title
        movie.hasWatched = hasWatched
        movie.identifier = identifier
        put(movie: movie)
        try! CoreDataStack.shared.save()
    }
    
    func deleteMovies(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = myURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            guard error == nil else {
                NSLog("delete error")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    func delete(movie: Movie, context: NSManagedObjectContext) {
        context.performAndWait {
            deleteMovies(movie: movie)
            context.delete(movie)
            try! CoreDataStack.shared.save(context: context)
        }
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
