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
    
    init() {
        fetchEntriesFromServer() { (_) in }
    }
    
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
            newMovie.hasWatched = false
            newMovie.title = title
            newMovie.identifier = UUID()
            putPostOrDeleteToFirebase(movie: newMovie, method: "PUT") { (_) in }
            saveToPersistentStore(context: CoreDataStack.shared.mainContext)
        }
    
    func updateMovie(movie: Movie, hasWatched: Bool?, movieRepresentation: MovieRepresentation?) {
        if let hasWatched = hasWatched {
            movie.hasWatched = hasWatched
            putPostOrDeleteToFirebase(movie: movie, method: "PUT") { (_) in }
            saveToPersistentStore(context: CoreDataStack.shared.mainContext)
        }
        else {
            guard let movieRepresentation = movieRepresentation else {return}
            movie.title = movieRepresentation.title
            movie.hasWatched = movieRepresentation.hasWatched!
            
        }
    }
        func deleteMovie(movie: Movie) {
            putPostOrDeleteToFirebase(movie: movie, method: "DELETE") { (_) in }
            CoreDataStack.shared.mainContext.delete(movie)
            self.saveToPersistentStore(context: CoreDataStack.shared.mainContext)
        }
    func getMovieFromPersistentStoreByTitle(title: String, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.predicate = predicate
        var movie: Movie?
        
        context.performAndWait {
            movie = (try? context.fetch(fetchRequest))?.first
        }
        
        return movie ?? nil
    }
    func getMovieFromPersistentStoreByIdentifier(identifier: String, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "identifier == %@", identifier)
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
                print("error initiaing dataTask: \(error)")
            }
            completionHandler(error)
            }.resume()
    }
    
func fetchEntriesFromServer(completionHandler: @escaping CompletionHandler) {
    let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
    let requestURL = firebaseURL?.appendingPathExtension("json")
    var request = URLRequest(url: requestURL!)
    request.httpMethod = "GET"
    
    URLSession.shared.dataTask(with: request) { (data, _, error) in
        if let error = error {
            print("error initiaing dataTask")
            completionHandler(error)
            return
        }
        backgroundContext.performAndWait {
            guard let data = data else {fatalError("Could not get data in 'GET' request.")}
            do {
                let results = try JSONDecoder().decode([String : MovieRepresentation].self, from: data)
                let movieRepresentations = results.map{ $0.value }
//                let movieRepresentations = movieRepresentationDictionaries.flatMap{ $0.values }
                self.iterateThroughMovieRepresentations(movieRepresentations: movieRepresentations, context: backgroundContext)
                self.saveToPersistentStore(context: backgroundContext)
                try! backgroundContext.save()
                completionHandler(nil)
            } catch {
                print(requestURL)
                print("error performing dataTask in fetchEntriesFromServer: \(error)")
            }
        }
        }.resume()
}
func iterateThroughMovieRepresentations(movieRepresentations: [MovieRepresentation], context: NSManagedObjectContext) {
    for movieRepresentation in movieRepresentations {
        let movie = self.getMovieFromPersistentStoreByIdentifier(identifier: movieRepresentation.identifier!, context: context)
        if movie != nil {
            self.updateMovie(movie: movie!, hasWatched: nil, movieRepresentation: movieRepresentation)
        } else {
            _ = Movie(title: movieRepresentation.title, hasWatched: movieRepresentation.hasWatched!, identifier: UUID(uuidString: movieRepresentation.identifier!)!, context: context).self
        }
    }
}
    
    
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    typealias CompletionHandler = (Error?) -> Void
    let firebaseURL = URL(string:"https://ios-movies-a964d.firebaseio.com/")
}
