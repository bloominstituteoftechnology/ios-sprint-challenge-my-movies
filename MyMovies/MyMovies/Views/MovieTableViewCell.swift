//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Linh Bouniol on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MovieTableViewCellDelegate {
    func toggleHasWatched(for cell: MovieTableViewCell)
}

class MovieTableViewCell: UITableViewCell {
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    var delegate: MovieTableViewCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    
    
    @IBAction func toggleWatchedStatus(_ sender: Any) {
        delegate?.toggleHasWatched(for: self)
        
        updateViews()
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        
        if movie.hasWatched == true {
            toggleButton.setTitle("Watched", for: .normal)
        } else {
            toggleButton.setTitle("Not Watched", for: .normal)
        }
    }
}
