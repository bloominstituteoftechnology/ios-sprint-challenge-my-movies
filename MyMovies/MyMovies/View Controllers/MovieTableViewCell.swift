//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Iyin Raphael on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MovieTableViewCellDelegate: class {
    func toggleHasWatchedOn(movie: Movie)
}

class MovieTableViewCell: UITableViewCell {

    func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        watchedButton.setTitle(movie.hasWatched ? "Watched" : "Unwatched", for: .normal)
    }
    
    
    weak var delegate: MovieTableViewCellDelegate?
    
    var movie: Movie? {
        didSet{
            updateViews()
        }
    }
    
    @IBAction func toggleHasWatched(_ sender: Any) {
        guard let movie = movie else { return }
        delegate?.toggleHasWatchedOn(movie: movie)
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    
}
