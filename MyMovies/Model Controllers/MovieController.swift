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
    
    // MARK: - Properties
    
    static let shared = MovieController()
    
    var searchedMovies: [MovieRepresentation] = []
    private let firebaseController = FirebaseController()
    
    // MARK: - Sync
    
    init() {
        syncAll()
    }
    
    // MARK: - Sync
    
    func syncAll(completion: @escaping CompletionHandler = { _ in }) {
        firebaseController.fetchMoviesFromServer { error, reps in
            if let error = error {
                print("Error fetching movies from server: \(error)")
                completion(error)
            }
            guard let movieReps = reps else {
                print("Error; no movies representations received.")
                completion(nil)
                return
            }
            self.updateLocalEntries(from: movieReps)
            self.updateServerEntries(using: movieReps)
            completion(nil)
        }
    }
    
    private func updateLocalEntries(from serverRepresentations: [MovieRepresentation]) {
        // This method is called from a network completion closure,
        // so a background context must be used.
        let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
        
        var error: Error?
        // Wait in case of error; then, if caught, handle it
        backgroundContext.performAndWait {
            let idsToFetch = serverRepresentations.compactMap { $0.identifier }
            let representationsByID = Dictionary(
                uniqueKeysWithValues: zip(idsToFetch, serverRepresentations)
            )
            var entriesToCreate = representationsByID
            
            let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "identifier IN %@", idsToFetch)
            do {
                let existingMovies = try backgroundContext.fetch(fetchRequest)
                for movie in existingMovies {
                    guard let id = movie.identifier,
                        let representation = representationsByID[id.uuidString]
                        else { continue }
                    update(movie: movie, from: representation)
                    entriesToCreate.removeValue(forKey: id.uuidString)
                }
                for representation in entriesToCreate.values {
                    let _ = Movie(representation: representation, context: backgroundContext)
                }
                try CoreDataStack.shared.save(context: backgroundContext)
            } catch let updateError {
                error = updateError
            }
        }
        if let caughtError = error {
            print("Error updating tasks from server: \(caughtError)")
        }
    }
    
    private func updateServerEntries(using serverMovieReps: [MovieRepresentation]) {
        // send local entries that aren't on server
        let idsOnServer = serverMovieReps.map { rep -> String in
            return rep.identifier!
        }
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            request.predicate = NSPredicate(format: "NOT (identifier IN %@)", idsOnServer)
            guard let moviesToSend: [Movie] = try? context.fetch(request) else {
                print("Error fetching unsynced movies")
                return
            }
            for movie in moviesToSend {
                if let rep = movie.movieRepresentation,
                    serverMovieReps.contains(rep) {
                    self.firebaseController.sendToServer(movie: movie)
                }
            }
        }
    }
    
    // MARK: - CRUD
    
    func update(movie: Movie, from representation: MovieRepresentation) {
        guard let id = representation.identifier?.uuid(),
            let hasWatched = representation.hasWatched
            else {
                print("rep missing id/haswatched")
                return
        }
        movie.title = representation.title
        movie.hasWatched = hasWatched
        movie.identifier = id
        update(movie: movie)
    }
    
    func update(movie: Movie) {
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("\(error)")
        }
        firebaseController.sendToServer(movie: movie)
    }
    
    func delete(movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        firebaseController.deleteMovieFromFirebase(movie)
        do {
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
        } catch {
            print("Error deleting movie: \(error)")
            return
        }
    }
    
    // MARK: - TMDB API
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        let queryParameters = [
            "query": searchTerm,
            "api_key": apiKey
        ]
        components?.queryItems = queryParameters.map({
            URLQueryItem(name: $0.key, value: $0.value)
        })
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
    
    func addMovieFromTMDB(movieRep: MovieRepresentation) {
        // TODO: prevent user from adding movie twice
        guard let movie = Movie(
            representation: movieRep,
            context: CoreDataStack.shared.mainContext
            ) else {
                print("Failed to add movie from TMDB; CoreData object initialization failed.")
                return
        }
        firebaseController.sendToServer(movie: movie)
    }
}
