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
            let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
            
            backgroundContext.performAndWait {
                do {
                    let movieRepresentations = try JSONDecoder().decode(MovieRepresentations.self, from: data).results
                    self.searchedMovies = movieRepresentations
                    for movieRep in self.searchedMovies {
                        if let convertedMovie = Movie(movieRepresentation: movieRep) {
                            self.movies.append(convertedMovie)
                            print("it converted")
                        } else {
                            print("nothing happened.")
                        }
                    }
                    try backgroundContext.save()
                    completion(nil)
                } catch {
                    NSLog("Error decoding JSON data: \(error)")
                    completion(error)
                }
            }
        
        }.resume()
    }
    
    func getMovieFromCoreData(movieTitle: String, context: NSManagedObjectContext) -> Movie? {
        //fetch request
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", movieTitle)
        var result: Movie? = nil
        //we are going to do this on a background context
        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                print("Error getting Movie from core data fetch request:\(error.localizedDescription)")
            }
        }
        return result
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    var movies: [Movie] = []
}
