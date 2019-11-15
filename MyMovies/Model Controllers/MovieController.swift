//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class MovieController {
    
    static var shared = MovieController()
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    // MARK: - Methods
    
    func createMovieFromRep(movieRepresentation: MovieRepresentation) {
        let context = CoreDataStack.shared.mainContext
        let _ = Movie(movieRepresentation: movieRepresentation, context: context)
        do {
            try CoreDataStack.shared.save(context: context)
            print("movie Created")
        } catch {
            print("Error saving movies")
            return
        }
    }
    
    func delete(movie: Movie) {
        
//        deleteEntryFromServer(entry) { error in
//            if let error = error {
//                print("Error deleting entry from server: \(error)")
//                return
//            }
            
            DispatchQueue.main.async {
                let moc = CoreDataStack.shared.mainContext
                moc.delete(movie)
                do {
                    try moc.save()
                } catch {
                    moc.reset()
                    print("Error saving managed object context: \(error)")
                }
            }
        }
    
    func updateMovieWatched(movie: Movie) {
        movie.hasWatched.toggle()
        let context = CoreDataStack.shared.mainContext
        do {
            try CoreDataStack.shared.save(context: context)
            print("movie updated")
        } catch {
            print("Error updating movie")
            return
        }
    }
    

    // MARK: - Helper Methods
    
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
