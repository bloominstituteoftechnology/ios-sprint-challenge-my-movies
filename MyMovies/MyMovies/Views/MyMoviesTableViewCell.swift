//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Sean Acres on 7/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MyMoviesTableViewCellDelegate: class {
    func hasWatchedTapped(on cell: MyMoviesTableViewCell)
}

class MyMoviesTableViewCell: UITableViewCell {

    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    var movieController: MovieController?
    weak var delegate: MyMoviesTableViewCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    @IBAction func hasWatchedTapped(_ sender: Any) {
        self.delegate?.hasWatchedTapped(on: self)
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        if movie.hasWatched {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
        
    }
}
