//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Lisa Sampson on 8/24/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MyMoviesTableViewCellDelegate: class {
    func hasWatchedButtonWasTapped(on cell: MyMoviesTableViewCell)
}

class MyMoviesTableViewCell: UITableViewCell {

    @IBAction func hasWatchedButtonTapped(_ sender: Any) {
        delegate?.hasWatchedButtonWasTapped(on: self)
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        
        if movie.hasWatched == false {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Watched", for: .normal)
        }
    }
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    weak var delegate: MyMoviesTableViewCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
}
