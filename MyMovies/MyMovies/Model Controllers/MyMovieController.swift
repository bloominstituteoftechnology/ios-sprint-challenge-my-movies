//
//  MyMovieController.swift
//  MyMovies
//
//  Created by Jonathan Ferrer on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

let baseURL = URL(string: "https://movies-97d15.firebaseio.com/")!

class MyMovieController {

    typealias CompletionHandler = (Error?) -> Void

    init() {
        fetchMoviesFromServer()
    }

    func fetchSingleMovie(forUUID uuid: UUID, in context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)

        var result: Movie? = nil
        context.performAndWait {
            do {
                result = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching movie with uuid \(uuid): \(error)")
            }
        }
        return result
    }
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
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
                let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
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


    private func updateMovies(with representations: [MovieRepresentation], context: NSManagedObjectContext) throws {

        var error: Error? = nil
        context.performAndWait {
            for movieRep in representations {
                guard let uuid = movieRep.identifier else { continue }

                if let movie = self.fetchSingleMovie(forUUID: uuid, in: context) {
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


    func update(movie: Movie, with rep: MovieRepresentation) {
        guard let hasWatched = rep.hasWatched else { return }
        movie.title = rep.title
        movie.hasWatched = hasWatched
    }

    func deleteMovieFromServer(_ movie: Movie, completion: @escaping ((Error?) -> Void) = { _ in }) {
        guard let identifier = movie.identifier else {
            completion(NSError())
            return
        }

        let requestURL = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(response!)
            completion(error)
            }.resume()
    }

    func putOnServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {

        let identifier = movie.identifier ?? UUID()
        let requestURL = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"

        do {
            guard var representation = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            representation.identifier = identifier
            movie.identifier = identifier

            try CoreDataStack.shared.save()

            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding movie \(movie): \(error)")
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
            print("Added to server")
            }.resume()
    }





}
