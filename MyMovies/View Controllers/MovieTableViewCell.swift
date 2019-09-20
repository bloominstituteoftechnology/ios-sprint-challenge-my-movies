//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by brian vilchez on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }

    private func updateViews() {
        guard let movie = movie else {return}
        titleLabel.text = movie.title
        hasWatchedButton.setTitle("unwatched", for: .normal)
        
    }
    
    @IBAction func hasWatchedButton(_ sender: UIButton) {
    }
}
