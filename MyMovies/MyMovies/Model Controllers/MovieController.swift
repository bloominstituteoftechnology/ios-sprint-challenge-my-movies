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
    
    
    // MARK: - FireBase
    
    let fireBaseURL = URL(string: "https://mymovies-9a2a0.firebaseio.com/")!
    
    typealias CompletionHandler = (Error?) -> Void
    
    func fetchTasksFromServer(completion: @escaping CompletionHandler = { _ in }) {
        
        let requestURL = fireBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion(error)
                return
            }
            guard let data = data else {
                NSLog("No data returned by data task")
                completion(NSError())
                return
            }
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                let moc = CoreDataStack.shared.container.newBackgroundContext()
                try self.updateMovies(with: movieRepresentations, context: moc)
                completion(nil)
            } catch {
                NSLog("Error decoding movie representations: \(error)")
                completion(error)
                return
            }
            }.resume()
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping (CompletionHandler) = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = fireBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(response!)
            completion(error)
            }.resume()
    }
    
    private func updateMovies(with representations: [MovieRepresentation], context: NSManagedObjectContext) throws {

        var error: Error? = nil

        context.performAndWait {

            for movieRep in representations {
                guard let uuid = movieRep.identifier else { continue }

                if let movie = self.movie(forUUID: uuid, in: context) {
                    self.update(movie: movie, with: movieRep)
                } else {
                    let _ = Movie(movieRepresentation: movieRep, context: context)
                }
            }

            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        if let error = error { throw error }
    }

    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched!
    }
    
    private func movie(forUUID uuid: UUID, in context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        
        var result: Movie? = nil
        
        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching task with uuid: \(uuid): \(error)")
            }
        }
        return result
    }
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = fireBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard var representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            representation.identifier = uuid
            movie.identifier = uuid
            try saveToPersistentStore()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding movie \(movie): \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTing task to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    func saveToPersistentStore() throws {
        let moc = CoreDataStack.shared.mainContext
        try moc.save()
    }
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
