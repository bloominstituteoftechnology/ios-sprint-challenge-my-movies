//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Nathan Hedgeman on 8/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    //Properties
    @IBOutlet var myMovieTitle: UILabel!
    @IBOutlet var seenNotSeenButton: UIButton!
    var delegate: MovieTableViewCellDelegate?
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let movie = self.movie else { return }
        self.myMovieTitle.text = movie.title
        if movie.hasWatched == true {
            self.seenNotSeenButton.setTitle("Watched", for: .normal)
        } else {
            self.seenNotSeenButton.setTitle("Unwatched", for: .normal)
        }
    }

    
    // Mark: - IBActions and Methods
    @IBAction func seenNotseen(_ sender: Any) {
        delegate?.toggleHasBeenSeen(for: self)
    }

}
