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
    
        
    func saveToPersistentStore(context: NSManagedObjectContext) {
            do {
                try context.save()
            } catch {
                fatalError("Failed to saveToPersistentStore:\(error)")
            }
        }
        func createMovie(title: String, hasWatched: Bool, identifier: UUID){
            let newMovie = Movie(context: CoreDataStack.shared.mainContext)
            newMovie.title = title
            newMovie.identifier = UUID()
            putPostOrDeleteToFirebase(movie: newMovie, method: "POST") { (_) in }
            saveToPersistentStore(context: CoreDataStack.shared.mainContext)
        }
        func updateMovie(movie: Movie, hasWatched: Bool) {
            movie.hasWatched = hasWatched
            putPostOrDeleteToFirebase(movie: movie, method: "PUT") { (_) in }
            saveToPersistentStore(context: CoreDataStack.shared.mainContext)
        }
        func deleteMovie(movie: Movie) {
            putPostOrDeleteToFirebase(movie: movie, method: "DELETE") { (_) in }
            CoreDataStack.shared.mainContext.delete(movie)
            self.saveToPersistentStore(context: CoreDataStack.shared.mainContext)
        }
    func getMovieFromPersistentStore(title: String, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.predicate = predicate
        var movie: Movie?
        
        context.performAndWait {
            movie = (try? context.fetch(fetchRequest))?.first
        }
        
        return movie ?? nil
    }

    func putPostOrDeleteToFirebase(movie: Movie, method: String, completionHandler: @escaping CompletionHandler) {
        let requestURL = firebaseURL?.appendingPathComponent((movie.identifier?.uuidString)!).appendingPathExtension("json")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = method
        do {
            request.httpBody = try JSONEncoder().encode(movie)
        } catch {
            print("error encoding 'Entry' object into JSON")
            completionHandler(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("error initiaing dataTask")
            }
            completionHandler(error)
            }.resume()
    }
    
    
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    typealias CompletionHandler = (Error?) -> Void
    let firebaseURL = URL(string:"https://ios-movies-a964d.firebaseio.com/")
}
