//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Diante Lewis-Jolley on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import Foundation

protocol MovieTableViewCellDelegate {
    func toggleHasBeenWatched( on cell: MovieTableViewCell)
}

class MovieTableViewCell: UITableViewCell {
    var delegate: MovieTableViewCellDelegate?

    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title

    }


    @IBAction func hasBeenWatchedButtonTapped(_ sender: Any) {
        delegate?.toggleHasBeenWatched(on: self)
    }

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasBeenWatchedButton: UIButton!
    var movie: Movie? {
        didSet{
            updateViews()
        }
    }
    
}
