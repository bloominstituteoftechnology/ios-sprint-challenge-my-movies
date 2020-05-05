//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Juan M Mariscal on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    static let reuseIdentifier = "MyMovieCell"
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: IBActions
    
    @IBAction func hasSeenBtnTapped(_ sender: Any) {
        
        guard let movie = movie else { return }
        
        hasWatchedButton.setTitle((movie.hasWatched) ? "Unwatched" : "Watched", for: .normal)
        
        if movie.hasWatched {
            movie.hasWatched = false
            movie.priority = SeenPriority.unwatched.rawValue
        } else {
            movie.hasWatched = true
            movie.priority = SeenPriority.watched.rawValue
        }
        
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }

    
    private func updateViews() {
        guard let movie = movie else { return }
        
        movieTitleLabel.text = movie.title
        hasWatchedButton.setTitle((movie.hasWatched) ? "Watched" : "Unwatched", for: .normal)
    }

}
