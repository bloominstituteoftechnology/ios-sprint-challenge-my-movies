//
//  DBMovieListCell.swift
//  MyMovies
//
//  Created by Sameera Roussi on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class DBMovieListCell: UITableViewCell {
    
    let myMovieController = MyMoviesController()
    
        var mymovies: [Movie] {
            return loadFromPresistentStore()
        }

    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        guard let addThisMovie = textLabel?.text else { return }
        create(title: addThisMovie, hasWatched: false)
    }
    
    /* ======================================================================== */
    
    func saveToPersistentStore()  throws {
        let moc = CoreDataStack.shared.mainContext
        try moc.save()
    }
    
    /* ======================================================================== */
    
    func create(title: String, hasWatched: Bool) {
        let movie = Movie(title: title, hasWatched: hasWatched)
        
        myMovieController.put(movie)
        
        do {
            try saveToPersistentStore()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
       
    }
    
    
    
    
    var selectedMovie: String?
}
