//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//
import CoreData
import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

class MovieController {
    
    typealias CompletionHandler = (Error?) -> Void
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let fireBaseURL = URL(string: "https://mymovies-e959b.firebaseio.com/")!
    
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
    
    
    private func put(movie: Movie, completion: @escaping CompletionHandler = {_ in }) {
        let requestURL = fireBaseURL.appendingPathComponent(movie.identifier?.uuidString ?? UUID().uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard let title = movie.title else { return }
        let rep = MovieRepresentation(title: title, identifier: movie.identifier, hasWatched: movie.hasWatched)
        
        do {
            request.httpBody = try JSONEncoder().encode(rep)
        } catch {
            print("Error could not encode movie: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error putting Movie to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    
    func createMovie(with title: String, identifier: UUID, hasWatched: Bool) {
        let movie = Movie(title: title, identifier: identifier, hasWatched: hasWatched)
        put(movie: movie)
        try? CoreDataStack.shared.save()
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = {_ in}) {
        guard let identifier = movie.identifier else {
            print("Movie identifier is nil")
            completion(NSError())
            return
        }
        let requestURL = fireBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            print(response!)
            DispatchQueue.main.async {
                completion(error)
            }
        }.resume()
    }
    
    func updateMovies(with reoresentation: [MovieRepresentation]) throws {
        let moviesWithId = reoresentation.filter { $0.identifier != nil }
        let identifiersToFetch = moviesWithId.compactMap { $0.identifier! }
        let repByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithId))
        
        var moviesToCreate = repByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            do {
                let existingMovies = try context.fetch(fetchRequest)
                for movie in existingMovies {
                    guard let id = movie.identifier, let representation = repByID[id] else { continue }
                    
                    
                }
            } catch {
                print("Error fetching movies: \(error)")
            }
        }
    }
    
    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = 
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
