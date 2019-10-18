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
    
     // MARK: - Properties
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let fireBaseURL = URL(string: "https://mymovies-9f7f0.firebaseio.com")
    var searchedMovies: [MovieRepresentation] = []
    
    // MARK: - C.R.U.D Methods
    func addMovie(withTitle title: String, context: NSManagedObjectContext) {
        
    }
    
    func deleteMovie(_ movie: Movie) {
        
    }
    
    func updateMovie(_ movie: Movie) {
        
    }
}


// this extension for the Movie API.
extension MovieController {
   
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
       
}
