//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Hunter Oppel on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func toggleWatched(_ sender: UIButton) {
        movie?.hasWatched.toggle()
        
        hasWatchedButton.setTitle(movie?.hasWatched ?? false ? "Watched" : "Not Watched", for: .normal)
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    private func updateViews() {
        movieTitleLabel.text = movie?.title
        hasWatchedButton.setTitle(movie?.hasWatched ?? false ? "Watched" : "Not Watched", for: .normal)
    }
}
