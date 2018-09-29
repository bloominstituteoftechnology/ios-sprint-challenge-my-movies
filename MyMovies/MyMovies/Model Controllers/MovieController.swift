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
    
    // MARK: - Initializer
    
    init(){
        fetchFromServer()
    }
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    let baseURL2 = URL(string: "https://mymovie-ilqarilyasov.firebaseio.com/")!
    
    typealias CompletionHandler = (Error?) -> Void
    
    
    // MARK: - CRUD Create
    
    func createMovie(title: String, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        let movie = Movie(title: title)
        
        do {
           try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error creating a movie: \(error)")
        }
        
        putMovieToServer(movie: movie)
        
    }
    
    
    // MARK: - CRUD Update
    
    func updateWatchStatus(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        if movie.hasWatched == true {
            movie.hasWatched = false
        } else {
            movie.hasWatched = true
        }
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            NSLog("Error updating movie watch status: \(error)")
        }
        
        putMovieToServer(movie: movie)
    }
    
    
    // MARK: - CRUD Delete
    
    func deleteMovie(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        deleteMovieFromServer(movie: movie)
        
        do {
            context.delete(movie)
            try context.save()
        } catch {
            context.reset()
            NSLog("Error deleting movie: \(error)")
        }
    }
}
