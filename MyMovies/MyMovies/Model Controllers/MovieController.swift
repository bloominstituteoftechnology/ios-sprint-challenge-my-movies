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
    private let movieURL = URL(string: "https://mymovies-5c516.firebaseio.com/")! 
    
    init() {
        fetchMoviesFromServer()
    }
    
    //MARK: MOVIE DB API Search
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
    
    
    
    //Mark: Firebase DB Methods
    func put(movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        
        let uuid = movie.identifier ?? UUID()
        let requestURL = movieURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movie)
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error PUTting movie to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func deleteFromServer(movie: Movie, completion:@escaping ((Error?) -> Void) = { _ in }) {
        
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(response!)
            completion(error)
            }.resume()
    }
    
    func fetchMoviesFromServer(completion: @escaping ((Error?) -> Void) = { _ in }) {
        
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching Entry: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            var movieRepresentation: [MovieRepresentation] = []
            do {
                movieRepresentation = try JSONDecoder().decode([String : MovieRepresentation].self, from: data).map({ $0.value })
                
            } catch {
                NSLog("Error decoding JSON: \(error)")
                completion(error)
                return
            }
            
            let moc = CoreDataStack.shared.container.newBackgroundContext()
            
            moc.performAndWait {
                
                for movieRepresentation in movieRepresentation {
                    
                    guard let uuid = UUID(uuidString: movieRepresentation.identifier!) else { continue }
                    
                    let movie = self.fetchSingleMovieFromPersistentStore(identifier: uuid, context: moc)
                    
                    if let movie = movie, movie != movieRepresentation {
                        self.update(movie: movie, with: movieRepresentation)
                        
                        print("Movie \(movieRepresentation.title) has been updated")
                    } else if movie == nil {
                        _ = Movie(movieRepresentation: movieRepresentation, context: moc)
                        print("Movie \(movieRepresentation.title) has been created")
                    }
                }
                do {
                    try CoreDataStack.shared.save(context: moc)
                } catch {
                    NSLog("Error saving background context: \(error)")
                }
                completion(nil)
            }
            
            }.resume()
        
    }
    
    func fetchSingleMovieFromPersistentStore(identifier: UUID, context: NSManagedObjectContext) -> Movie? {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier as NSUUID)
        
        var movie: Movie?
        
        context.performAndWait {
            do {
                movie = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching single entry: \(error)")
            }
        }
        return movie
    }
    
    
    // Mark: CRUD Methods
    func create(title: String, watched: Bool) {
        
        let movie = Movie(title: title, watched: watched)
        saveToPersistentStore()
        put(movie: movie)
    
    }
    
    func update(movie: Movie, with er: MovieRepresentation) {
        
        movie.title = er.title
        movie.watched = !movie.watched
        saveToPersistentStore()
        put(movie: movie)
    }
    
    func updateWatchedButton(movie: Movie) {
        movie.watched = !movie.watched
        put(movie: movie)
        
    }
    // MARK: - Persistent Store
    
    func saveToPersistentStore() {
    
        let moc = CoreDataStack.shared.mainContext
    
        do {
            try moc.save()
        } catch {
            NSLog("Error saving managed object context\(error)")
        }
    }
    
//    func loadFromPersistentStore() -> [Movie] {
//        let fetchRequest: NSFetchRequest<Movie> = Entry.fetchRequest()
//        let moc = CoreDataStack.shared.mainContext
//        
//        do {
//            return try moc.fetch(fetchRequest)
//            
//        } catch {
//            NSLog("Error fetching entry: \(error)")
//            return []
//        }
//    }

    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
