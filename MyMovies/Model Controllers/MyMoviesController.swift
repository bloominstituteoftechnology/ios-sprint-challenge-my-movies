//
//  MyMoviesController.swift
//  MyMovies
//
//  Created by Joel Groomer on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MyMoviesController {
    let baseURL = ""
    typealias CompletionHandler = (Error?) -> Void
    
    
    // MARK: - Local Store Methods
    
    func addMovie(representation: MovieRepresentation) {
        
    }
    
    func toggleSeen(movie: Movie) {
        
    }
    
    func toggleSeen(representation: MovieRepresentation) {
        
    }
    
    func deleteMovie(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
    }
    
    func update(movie: Movie, with representation: MovieRepresentation) {
        
    }
    
    func updateMovies(with representations: [MovieRepresentation]) {
        
    }
    
    
    // MARK: - Server Methods
    
    private func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
    }
    
    private func deleteFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
    }
    
    
}
