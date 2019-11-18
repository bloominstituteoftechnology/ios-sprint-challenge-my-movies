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
    
    typealias CompletionHandler = (Error?) -> Void
    
//    init() {
//        fetchMoviesFromServer()
//    }
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
        private let firebaseURL = URL(string: "https://tsb-mymovies.firebaseio.com/")!
    
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
    

    
  
  func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {

      let requestURL = firebaseURL.appendingPathExtension("json")

      URLSession.shared.dataTask(with: requestURL) { data, _, error in
          if let error = error {
              print("Error fetching movies: \(error)")
              completion(error)
              return
          }

          guard let data = data else {
              print("No data returned by data task")
              completion(NSError())
              return
          }

          do {
              let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
              try self.updateMovies(with: movieRepresentations)
              completion(nil)
          } catch {
              print("Error decoding movie representations: \(error)")
              completion(error)
              return
          }

      }.resume()
  }
    
    private func updateMovies(with representations: [MovieRepresentation]) throws {
        let moviesWithID = representations.filter{ $0.identifier != nil }
        let identifiersToFetch = moviesWithID.compactMap {$0.identifier!}

        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))

        var moviesToCreate = representationsByID

        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)

        let context = CoreDataStack.shared.container.newBackgroundContext()

        do {
            let existingTasks = try context.fetch(fetchRequest)
            for movie in existingTasks {
                guard let id = movie.identifier,
                    let representation = representationsByID[id] else { continue }

                self.update(movie: movie, with: representation)
                moviesToCreate.removeValue(forKey: id)
            }

            for representation in moviesToCreate.values {
               Movie(movieRepresentation: representation)
            }
        } catch {
            print("Error fetching movies for UUIDs: \(error)")
        }
        try CoreDataStack.shared.save(context: context)
    }
    
    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.identifier = representation.identifier
        movie.hasWatched = representation.hasWatched ?? false
        
        
    }
    
    
    func sendTaskToServer(movie: Movie, completion: @escaping () -> () = { }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var representation = movie.movieRepresentation else {
                completion()
                return
            }
            
            movie.identifier = uuid
            representation.identifier = uuid
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding task: \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            completion()
            
            if let error = error {
                print("Error PUTing task to server; \(error)")
            }
            if let response = response {
                print("\(response)")
            }
        }.resume()
    }
    // MARK: - Properties
    
    func deleteMovie(_ movie: Movie, completion: @escaping (CompletionHandler) = { _ in }) {
           guard let uuid = movie.identifier else {
               completion(NSError())
               return
           }
           
           let context = CoreDataStack.shared.mainContext
           
           do {
               context.delete(movie)
               try CoreDataStack.shared.save(context: context)
           } catch {
               context.reset()
               print("Error deleting object from managed object context:\(error)")
           }
           
           let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
           var request = URLRequest(url: requestURL)
           request.httpMethod = "DELETE"
           URLSession.shared.dataTask(with: request) { data, response, error in
               print(response!)
               completion(error)
           }.resume()
       }
    
    var searchedMovies: [MovieRepresentation] = []
}
