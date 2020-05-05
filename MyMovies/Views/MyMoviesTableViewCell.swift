//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by David Williams on 5/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var haveWatchedButtonLabel: UIButton!
    
    let movieController = MovieController()
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        if movie.hasWatched {
            haveWatchedButtonLabel.setTitle("Seen", for: .normal)
        } else {
            haveWatchedButtonLabel.setTitle("Unseen", for: .normal)
        }
    }
    
    @IBAction func haveWatched(_ sender: Any) {
        guard let movie = movie else { print("No Movie"); return }
        movie.hasWatched.toggle()
        
        updateViews()
        movieController.put(movie: movie) { _ in }
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
}
