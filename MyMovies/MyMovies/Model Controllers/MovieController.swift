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
    private let fireBaseBaseURL = URL(string: "https://mymovies-bb595.firebaseio.com/")!
    
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
}

extension MovieController {
    func addMovie(title: String, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            let movie = Movie(title: title)
            
            do{
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving context when adding movie: \(error)")
            }
            putToServer(movie: movie)
        }
        
    }
    func updateHasWatched(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            movie.hasWatched.toggle()
            do{
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving context when updating movie: \(error)")
            }
            putToServer(movie: movie)
        }
    }
    func deleteMovie(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        context.performAndWait {
            context.delete(movie)
            
            do{
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving context when deleting movie: \(error)")
            }
            
        }
    }
}

extension MovieController {
    
    func fetchMyMovieFromServer(completion: @escaping () -> Void) {
        let requestURL = baseURL.appendingPathExtension("json")
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movie from server: \(error)")
                completion()
                return
            }
            guard let data = data else {
                NSLog("No data returned from data task")
                completion()
                return
            }
            
            do {
                let myMoviesRepDict = try JSONDecoder().decode([String : MovieRepresentation].self, from: data)
                let myMoviesRep = myMoviesRepDict.map({$0.value})
                let moc = CoreDataStack.shared.container.newBackgroundContext()
                
                self.updatePersistentStore(movieReps: myMoviesRep, context: moc)
                
            } catch {
                NSLog("Error decoding movie from server \(error)")
            }
            completion()
        }.resume()
        
    }
    
    func updatePersistentStore(movieReps: [MovieRepresentation], context: NSManagedObjectContext) {
        context.performAndWait {
            for movieRep in movieReps {
                guard let identifier = movieRep.identifier else { continue }
                
                if let movie = fetchSingleMovieFromPersistent(identifier: identifier, context: context) {
                    if movie != movieRep {
                        // not the same, update
                        self.updateHasWatched(movie: movie)
                    }
                } else {
                    //entry does not exist, create one
                    Movie(movieRepresentation: movieRep, context: context)
                }
            }
            
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving when fetching from server: \(error)")
                context.reset()
            }
        }
    }
    
    func fetchSingleMovieFromPersistent(identifier: UUID, context: NSManagedObjectContext) -> Movie? {
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", identifier as NSUUID)
        let movie = try! context.fetch(request).first
        return movie
    }
    
    func putToServer(movie: Movie, completion: @escaping () -> Void = {}) {
        let identifier = movie.identifier ?? UUID()
        let requestURL = fireBaseBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        do {
            let data = try JSONEncoder().encode(movie.movieRepresentation)
            print(data)
            request.httpBody = data
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion()
            return
        }
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error putting data: \(error)")
            }
            completion()
        }.resume()
    }
}

enum HTTPMethod: String{
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}
