//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Nichole Davidson on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!

   
    
    @IBAction func hasWatched(_ sender: UIButton) {
        guard let movie = movie else { return }
        
        movie.hasWatched.toggle()
        
        if movie.hasWatched == true {
            sender.setTitle("Watched", for: .normal)
        } else {
            sender.setTitle("Unwatched", for: .normal)
        }
        
//        sender.setTitle(movie.hasWatched ? "Watched" : "Unwatched", for: .normal)
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        
        movieTitleLabel.text = movie.title
        hasWatchedButton.setTitle(movie.hasWatched ? "Watched" : "Unwatched", for: .normal)
    }

}
