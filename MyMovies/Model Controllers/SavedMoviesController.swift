//
//  SavedMoviesController.swift
//  MyMovies
//
//  Created by Eoin Lavery on 14/10/2019.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class SavedMoviesController {
    
    //MARK: - PROPERTIES
    //A static instance of this class to have a single accessible instance available throughout the app.
    static let shared = SavedMoviesController()
    
    //MARK: - FUNCTIONS FOR LOCAL STORAGE
    func toggleHasWatched(for movie: Movie) {
        do {
            movie.hasWatched.toggle()
            try CoreDataStack.shared.save()
        } catch {
            print("Error updating hasWatched value for movie '\(movie.title ?? "blank movie")': \(error)")
        }
    }
    
    func addMovie(for representation: MovieRepresentation) {
        guard let _ = Movie(movieRepresentation: representation) else { return }
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error saving new movie to local storage: \(error)")
        }
    }
    
    func deleteMovie(for movie: Movie, completion: @escaping (Error?) -> Void = { _ in }) {
        CoreDataStack.shared.mainContext.delete(movie)
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error deleting movie from local storage: \(error)")
            CoreDataStack.shared.mainContext.reset()
        }
        
        completion(nil)
    }
    
    //MARK: - FUNCTIONS FOR ONLINE STORAGE
}
