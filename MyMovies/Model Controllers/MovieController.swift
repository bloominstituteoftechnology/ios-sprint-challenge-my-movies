//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class MovieController {
    
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
    var movieRepresentation: MovieRepresentation?
    let moc = CoreDataStack.shared.mainContext
    
    // Core data
    var firebaseURL = URL(string: "https://my-movies-2e66b.firebaseio.com/")
    typealias CompletionHandler = (Error?) -> Void

    init() {
        ()
    }
    
    func saveToPersistentStore() {
        do {
            try moc.save()
        } catch {
            moc.reset()
            print("Error saving to persistent store: \(error)")
        }
    }
    
    func addMovie(withTitle title: String) {
        let movie = Movie(title: title, hasWatched: false)
        
        put(movie: movie)
        saveToPersistentStore()
    }
    
    func deleteMovie(movie: Movie) {
        moc.delete(movie)
        saveToPersistentStore()
    }
    
    
    //PUTting the entry onto firebase
       private func put(movie: Movie, completion: @escaping CompletionHandler = { _ in}) {
           let uuid = movie.identifier ?? UUID()
        let requestURL = firebaseURL!.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
           var request = URLRequest(url: requestURL)
           request.httpMethod = "PUT"
           
           do {
            guard var representation =  movie.movieRepresentation else {
                   completion(NSError())
                   return
               }
            
               movie.identifier = uuid
               try saveToPersistentStore()
               request.httpBody = try JSONEncoder().encode(representation)
               } catch {
                   print("Error encoding entry \(movie): \(error)")
                   completion(error)
                   return
           }
           
          URLSession.shared.dataTask(with: request) { (data, _, error) in
               guard error == nil else {
                   print("Error PUTting task to server: \(error!)")
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

    }
    
    
    

