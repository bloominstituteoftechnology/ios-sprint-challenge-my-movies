//
//  MovieModelController.swift
//  MyMovies
//
//  Created by Christopher Aronson on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String {
    case PUT
    case GET
    case POST
    case DELETE
}

class MovieModelController {

    let baseURL = URL(string: "https://mymovies-fad37.firebaseio.com/")!

    init() {
        fetchMoviesFromServer { _ in
            
        }
    }

    func save(contetex: NSManagedObjectContext) {

        contetex.performAndWait {
            do {
                try contetex.save()
            } catch  {
                NSLog("Could Not save data to persistent Stores: \(error)")
            }
        }
    }

    func create(title: String) {

        let movie = Movie(title: title)

        put(movie: movie) {  _ in

        }
    }

    func update(movie: Movie, hasWatch: Bool) {
        movie.hasWatched = hasWatch

        put(movie: movie) {  _ in

        }
    }

    func delete(movie: Movie, context: NSManagedObjectContext) {

        deleteFromServer(movie: movie) { _ in

        }
        context.delete(movie)
    }

    func put(movie: Movie, completion: @escaping (Error?) -> Void) {

        let requestURl = baseURL
            .appendingPathComponent(movie.identifier?.uuidString ?? UUID().uuidString)
            .appendingPathExtension("json")

        var request = URLRequest(url: requestURl)
        request.httpMethod = HTTPMethod.PUT.rawValue

        do {
            guard let movie = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            request.httpBody = try JSONEncoder().encode(movie)

        } catch  {
            NSLog("Error encoding TaskRepresentation: \(error)")
            completion(error)
            return
        }

        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTting TaskRepresentation to Firebase: \(error)")
                completion(error)
                return
            }

            completion(nil)
            }.resume()
    }

    func deleteFromServer(movie: Movie, completion: @escaping (Error?) -> Void) {

        let requestURl = baseURL
            .appendingPathComponent(movie.identifier?.uuidString ?? UUID().uuidString)
            .appendingPathExtension("json")

        var request = URLRequest(url: requestURl)
        request.httpMethod = HTTPMethod.DELETE.rawValue

        do {
            guard let movie = movie.movieRepresentation else {
                completion(NSError())
                return
            }
            request.httpBody = try JSONEncoder().encode(movie)

        } catch  {
            NSLog("Error encoding TaskRepresentation: \(error)")
            completion(error)
            return
        }

        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTting TaskRepresentation to Firebase: \(error)")
                completion(error)
                return
            }

            completion(nil)
            }.resume()
    }

    func fetchMoviesFromServer(completion: @escaping (Error?) -> Void) {

        let requestURL = baseURL.appendingPathExtension("json")

        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in

            if let error = error {
                NSLog("Error fetching movie from server: \(error)")
                completion(error)
                return
            }

            guard let data = data else {
                NSLog("No data returned from data movie")
                completion(NSError())
                return
            }

            do {
                let movieRepresentationData = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
                let movieRepresentation = Array(movieRepresentationData.values)

                try self.updateMovies(with: movieRepresentation)

            } catch {
                NSLog("Error decoding MoiveRepresentation and adding them to persistent store: \(error)")
                completion(error)
                return
            }
        }.resume()
    }

    func updateMovies(with movieRepresentations: [MovieRepresentation]) throws {

        let context = CoreDataStack.shared.container.newBackgroundContext()

        context.performAndWait {

            for movieRepresentation in movieRepresentations {

                guard let identifier = movieRepresentation.identifier?.uuidString else { continue }

                if let movie = fetchSingleMovieFromStore(forID: identifier, context: context) {

                    movie.title = movieRepresentation.title
                    movie.identifier = movieRepresentation.identifier
                    movie.hasWatched = movieRepresentation.hasWatched ?? true
                } else {
                    _ = Movie(movieRepresentation: movieRepresentation, context: context)
                }

            }
        }

        try CoreDataStack.shared.save(context: context)
    }

    func fetchSingleMovieFromStore(forID identifier: String, context: NSManagedObjectContext) -> Movie? {

        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)

        do {
            return try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching task with UUID \(identifier): \(error)")
            return nil
        }
    }
}
