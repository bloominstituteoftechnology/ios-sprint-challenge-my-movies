//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by patelpra on 5/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var myMovieTitle: UILabel!
    @IBOutlet weak var seenNotSeenButton: UIButton!
    
    var movie: Movie? {
        didSet {
            self.updateViews()
        }
    }
    
    weak var delegate: MovieTableViewCellDelegate?
    
    private func updateViews() {
        guard let movie = self.movie else { return }
        
        self.myMovieTitle.text = movie.title
        
        if movie.hasWatched == true {
            self.seenNotSeenButton.setTitle("Watched", for: .normal)
        } else {
            self.seenNotSeenButton.setTitle("Unwatched", for: .normal)
        }
    }
    
    
    @IBAction func seenNotSeen(_ sender: Any) {
        delegate?.toggleHasBeenSeen(for: self)
    }
}
