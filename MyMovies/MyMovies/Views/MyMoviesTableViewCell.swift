//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Lisa Sampson on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

// MARK: - Protocols
protocol MyMoviesTableViewCellDelegate: class {
    func hasWatchedButtonTapped(on cell: MyMoviesTableViewCell)
}

class MyMoviesTableViewCell: UITableViewCell {

    // MARK: - Properties and Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    weak var delegate: MyMoviesTableViewCellDelegate?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - View Loading
    func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        
        if movie.hasWatched == false {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Watched", for: .normal)
        }
    }
    
    // MARK: - Actions
    @IBAction func hasWatchedButtonTapped(_ sender: Any) {
        delegate?.hasWatchedButtonTapped(on: self)
    }
}
