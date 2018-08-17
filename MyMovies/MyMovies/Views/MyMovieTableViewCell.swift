//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Samantha Gatt on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    var movieController: MovieController?
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var myMovieTitleLabel: UILabel!
    @IBOutlet weak var hasSeenButton: UIButton!
    
    
    // MARK: - Actions
    
    @IBAction func toggleHasSeen(_ sender: Any) {
        guard let movie = movie else { return }
        movieController?.toggleHasWatched(movie: movie, context: CoreDataStack.moc)
    }
    
    
    // MARK: - Functions
    
    func updateViews() {
        guard let thisMovie = movie else { return }
        myMovieTitleLabel.text = thisMovie.title
        
        let title = thisMovie.hasWatched == true ? "Unwatch" : "Watch"
        hasSeenButton.setTitle(title, for: .normal)
    }
}
