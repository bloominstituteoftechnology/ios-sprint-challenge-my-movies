//
//  MovieController.swift
//  MyMovies
//
//  Created by Shawn Gee on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

typealias MovieRepsByID = [String: MovieRepresentation]

class MovieController {
    private let firebaseClient = FirebaseClient()
    
    init() {
        fetchMoviesFromServer()
    }
    
    func fetchMoviesFromServer(completion: (() -> Void)? = nil) {
        firebaseClient.fetchMoviesFromServer { result in
            switch result {
            case .failure(let error):
                NSLog("Error fetching movies from server: \(error)")
            case .success(let movieRepsByID):
                self.syncMovies(with: movieRepsByID)
            }
            completion?()
        }
    }
    
    func addMovie(with representation: MovieRepresentation) {
        // Could add functionality to avoid duplication
        guard let movie = Movie(representation) else { return }
        try? CoreDataStack.shared.save()
        firebaseClient.sendMovieToServer(movie)
    }
    
    func save(_ movie: Movie) {
        try? CoreDataStack.shared.save()
        firebaseClient.sendMovieToServer(movie)
    }
    
    func delete(_ movie: Movie) {
        firebaseClient.deleteMovieWithID(movie.identifier)
        CoreDataStack.shared.mainContext.delete(movie)
        try? CoreDataStack.shared.save()
    }
    
    
    // MARK: - Syncing
    
    private func syncMovies(with movieRepsByID: MovieRepsByID) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        let moviesOnServerRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        moviesOnServerRequest.predicate = NSPredicate(format: "identifier IN %@", Array(movieRepsByID.keys))
        
        var moviesToCreate = movieRepsByID
        
        context.perform {
            if let existingMovies = try? context.fetch(moviesOnServerRequest) {
                for movie in existingMovies {
                    let id = movie.identifier
                    guard let representation = movieRepsByID[id] else { continue }
                    self.update(movie, with: representation)
                    moviesToCreate.removeValue(forKey: id)
                }
            }
            
            for representation in moviesToCreate.values {
                Movie(representation, context: context)
            }
            
            try? context.save()
        }
    }
    
    private func update(_ movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        if let hasWatched = representation.hasWatched {
            movie.hasWatched = hasWatched
        }
    }
}

