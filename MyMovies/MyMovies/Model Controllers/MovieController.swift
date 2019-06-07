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
        fetchMoviesFromServer()
    }



    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    // Firebase URL
    private let fireURL = URL(string:"https://movie-a455b.firebaseio.com/")!
    // Completion Error
    typealias CompletionHandler = (Error?) -> Void
    // MOC Data
    let moc = CoreDataStack.shared.mainContext
    
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

    // MARK: - MY CRUDS

    func addMovie(title: String) {

        let newMovie = Movie(title: title)
        put(movie: newMovie)
        saveToPersistentStore()

    }

    func delete(movie: Movie) {
        
        moc.delete(movie)
        deleteFromFetchedController(movie: movie)
        saveToPersistentStore()


    }



    func toggleHasBeenWatched(movie: Movie) {
       movie.hasWatched.toggle()
        
    }

    func put(movie: Movie, completion: @escaping CompletionHandler = {_ in}) {

        let uuid = movie.identifier ?? UUID()
        movie.identifier = uuid

        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")

        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"

        do {
            guard let representation = movie.movieRepresentation else { throw NSError() }

            request.httpBody = try JSONEncoder().encode(representation)

        } catch {
            NSLog("Error encoding entries: \(error)")
            completion(error)
            return
        }

        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error encoding entries to Server: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }

    func fetchMoviesFromServer(completion: @escaping CompletionHandler = {_ in }) {

        let requestURL = fireURL.appendingPathComponent("json")

        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching entries: \(error)")
                completion(error)
                return
            }
            guard let data = data else {
                NSLog("No data returned from the data entry: \(NSError())")
                completion(NSError())
                return
            }

            do {
                let movieRepDict = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
                let movieRep = Array(movieRepDict.values)

                // Create Background Context Here
                let backMoc = CoreDataStack.shared.container.newBackgroundContext()

                try self.updateMovie(with: movieRep, context: backMoc)
                completion(nil)


            } catch {
                NSLog("Error decoding entries: \(error)")
                completion(error)
                return

            }
    }.resume()
    }

    private func updateMovie(with representation: [MovieRepresentation], context: NSManagedObjectContext) throws {

        var error: Error? = nil
        // USE OF BACKGROUND CONTEXT PERFORM AND WAIT
        context.performAndWait {
            for movieRep in representation {
                guard let uuid = movieRep.identifier else { continue }

                if let movie = self.movie(forUUID: uuid, in: context) {
                    self.updateRep(movie: movie, with: movieRep)
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


    private func movie(forUUID uuid: UUID, in context: NSManagedObjectContext) -> Movie? {

        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)

        var result: Movie? = nil
        //USE OF PERFORM AND WAIT HERE
        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching task with uuid \(uuid): \(error)")

            }
        }

        return result
    }

    private func updateRep(movie: Movie, with representation: MovieRepresentation) {

        movie.title = representation.title
        movie.hasWatched = representation.hasWatched ?? false

    }

    func deleteFromFetchedController(movie: Movie, completion: @escaping CompletionHandler = {_ in}) {
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        movie.identifier = uuid

        let requestURL = fireURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")

        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting from server: \(error)")
                completion(error)
                return
            }

            completion(nil)
            }.resume()

    }
















    func saveToPersistentStore() {

        do {
            try moc.save()
        } catch {
            NSLog("Error saving to Persistent Store: \(error)")
        }
    }




    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
