//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class MovieController {
    
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        // nil coalesce will certainly assign uuid = UUID() here
        var uuid = movie.identifier ?? UUID()
        let requestURL = firebaseURL!.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")  //editor placeholder error, 10 minutes wasted: solution was command B
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            // put movie to be saved into temporary movieRepresentation instance
            guard var representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            representation.identifier = uuid
            try saveToPersistentStore()
            request.httpBody = try JSONEncoder().encode(representation)
                
        }
    }
    
    func saveToPersistentStore() {
        
        let moc = CoreDataStack.shared.container
        try moc.save() // now need to write save method in CoreDataStack
    }
    
    
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
    
    typealias CompletionHandler = (Error?) -> Void
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://mymovies-8e4fd.firebaseio.com/")
    
    var searchedMovies: [MovieRepresentation] = []
}
