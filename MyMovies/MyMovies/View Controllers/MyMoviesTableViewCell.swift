//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by jkaunert on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MyMoviesTableViewCell: UITableViewCell {
    
    let  myMoviesController = MyMoviesController()
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        
        guard let movie = movie else { return }
        myMovieTitleLabel.text = movie.title
        watchedButton.setTitle(movie.hasWatched ? "Watched" : "Not Watched", for: [])
        
        
    }
    
    @IBOutlet weak var myMovieTitleLabel: UILabel!
    
    @IBOutlet weak var watchedButton: UIButton!
    
    
    @IBAction func didWatchMovie(_ sender: UIButton) {
        guard let movie = movie else { return }
        movie.hasWatched = !movie.hasWatched
        
        do {
            try CoreDataStack.shared.save(context: movie.managedObjectContext!)
        } catch {
            NSLog("Error saving updated movie: \(error)")
            return
        }
        
        //Firebase save
        myMoviesController.putFirebase(movie: movie)
        
        updateViews()
    }
    
}
