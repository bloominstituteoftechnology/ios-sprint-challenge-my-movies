//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Tobi Kuyoro on 28/02/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol SeenMovieDelegate {
    func watched(movie: Movie)
}

class MyMovieTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets

    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    // MARK: - Properties
    
    var delegate: SeenMovieDelegate?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func hasWatchedButtonTapped(_ sender: UIButton) {
        guard let movie = movie else { return }
        delegate?.watched(movie: movie)
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        
        movieTitleLabel.text = movie.title
        
        if movie.hasWatched == true {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Not Watched", for: .normal)
        }
    }
}
