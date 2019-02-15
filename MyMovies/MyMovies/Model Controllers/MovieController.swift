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
    private let firebaseURL = URL(string: "https://movie-db-284b3.firebaseio.com/")!
    
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
    
    
    func createMovie(withName name: String, hasWatched: Bool) -> MovieRepresentation{
        let movie = MovieRepresentation(title: name)
        saveToPersistentStore()
        putMovie(movie)
        return movie
    }
    
    
    func putMovie(_ movie: MovieRepresentation, completion: @escaping (Error?) -> Void = {_ in}){
        let identifier = movie.identifier ?? UUID()
        let url = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathComponent("json")
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let jsonEncoder = JSONEncoder()
        do{
            request.httpBody = try jsonEncoder.encode(movie)
        }catch{
            NSLog("Unable to encode task representation: \(error)")
            completion(error)
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error{
                print(error)
                completion(error)
                return
            }
            completion(nil)
            }.resume()
        
        
    }
    
    
    func saveToPersistentStore(){
        let moc = CoreDataStack.shared.mainContext
        do{
            try moc.save()
        }catch{
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
