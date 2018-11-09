//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData


class MovieController: MyMovieCellDelegate {
    
    init() {
        fetchAllMoviesFromServer { (error) in
            if let error = error {
                NSLog("error fetching from server: \(error)")
                return
            }
        }
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
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    func saveToPersistenceStore() {
        let moc = CoreDataStack.shared.mainContext
        do {
//                        try moc.save()
            try CoreDataStack.shared.save(context: moc)
        } catch {
            NSLog("Could not save to disk: \(error)")
        }
    }
    
    func loadFromPersistentStore() -> [Movie] {
        let moc = CoreDataStack.shared.mainContext
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        do {
            return try moc.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
            return []
        }
    }
    
    func newMovie(title: String, hasWatched: Bool) -> Movie{
        let movie = Movie(title: title, hasWatched: hasWatched)
        
        saveToPersistenceStore()
        put(movie: movie)
        
        return movie
    }
    
    func stubToMovie(stub: MovieRepresentation) -> Movie{
        if stub.hasWatched == nil {
            return newMovie(title: stub.title, hasWatched: true)
        } else {
            return newMovie(title: stub.title, hasWatched: stub.hasWatched!)
        }
    }
    
    func fetchOneMovie(identifier: UUID) -> Movie? {
        let moc = CoreDataStack.shared.mainContext
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier.uuidString)
        //        do {
        //            return try moc.fetch(fetchRequest)[0]
        //        } catch {
        //            NSLog("Error fetching tasks: \(error)")
        //            return nil
        //        }
        
        var oneMovie: Movie?
        moc.performAndWait {
            do {
                oneMovie = try moc.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching tasks: \(error)")
            }
        }
        return oneMovie
    }
    
    func matchStubToMovie(movie: Movie, stub: MovieRepresentation) {
        movie.title = stub.title
        movie.identifier = stub.identifier
        movie.hasWatched = stub.hasWatched ?? false
    }
    
    func updateMovie(movie: Movie, title: String, hasWatched: Bool) {
        guard let moc = movie.managedObjectContext else {return}
        
        //        movie.setValue(title, forKey: "title")
        //        movie.setValue(hasWatched, forKey: "hasWatched")
        moc.performAndWait {
            movie.setValue(title, forKey: "title")
            movie.setValue(hasWatched, forKey: "hasWatched")
        }
        
        saveToPersistenceStore()
        //put(movie: movie)
    }
    
    func deleteMovie(movie: Movie) {
        let moc = CoreDataStack.shared.mainContext
        moc.delete(movie)
        deleteFromServer(movie: movie)
        saveToPersistenceStore()
    }
    
    // FireBase
    
    let fireBaseUrl: URL = URL(string: "https://iomymovies.firebaseio.com/")!
    
    func put(movie: Movie, completion: @escaping (_ error: Error? ) -> Void = { _ in }) {
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        var request = URLRequest(url: fireBaseUrl.appendingPathComponent(identifier.uuidString).appendingPathExtension("json"))
        request.httpMethod = "PUT"
        
        do {
            let data = try JSONEncoder().encode(movie)
            request.httpBody = data
        } catch {
            NSLog("Error encoding data: \(error)")
            completion(error)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                NSLog("Error creating database: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }
        dataTask.resume()
    }
    
    func deleteFromServer(movie: Movie, completion: @escaping (_ error: Error?) -> Void = {_ in }) {
        guard let identifier = movie.identifier else {fatalError("Movie has no identifier")}
        
        var request = URLRequest(url: fireBaseUrl.appendingPathComponent(identifier.uuidString).appendingPathExtension("json"))
        request.httpMethod = "DELETE"
        
        let dataTask = URLSession.shared.dataTask(with: request) {data, _, error in
            if let error = error {
                NSLog("Error creating dataTask: \(error)")
                completion(error)
                return
            }
            completion(nil)
            return
        }
        dataTask.resume()
    }
    
    // Sync Firebase
    func fetchAllMoviesFromServer( completion: @escaping (_ error: Error?) -> Void = {_ in}) {
        let url = fireBaseUrl.appendingPathExtension("json")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) {data, _, error in
            if let error = error {
                NSLog("Error creating dataTask: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else  {
                NSLog("No data: \(String(describing: error))")
                completion(error)
                return
            }
            
            var stubs: [MovieRepresentation] = []
            let decoder = JSONDecoder()
            do {
                let json = try decoder.decode([String: MovieRepresentation].self, from: data)
                for (_, entry) in json {
                    stubs.append(entry)
                }
                
            } catch {
                NSLog("Couldn not decode json into stubs: \(error)")
                completion(error)
                return
            }
            let moc2 = CoreDataStack.shared.container.newBackgroundContext()
            do {
                for stub in stubs {
                    guard let identifier = stub.identifier else {fatalError("Stub from server has no identifier")}
                    let movie = self.fetchOneMovie(identifier: identifier)
                    if movie != nil {
                        self.updateMovie(movie: movie!, title: stub.title, hasWatched: stub.hasWatched!)
                    } else {
                        
                        moc2.perform {
                            _ = self.stubToMovie(stub: stub)
                        }
                        //                    self.saveToPersistenceStore()
                    }
                }
                try CoreDataStack.shared.save(context: moc2)
            } catch {
                NSLog("Error decoding tasks: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }
        dataTask.resume()
    }
    
}
