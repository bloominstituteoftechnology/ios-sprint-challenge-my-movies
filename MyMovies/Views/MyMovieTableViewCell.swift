//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Eoin Lavery on 25/02/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MovieWasSeenDelegate {
    func movieWasWatched(movie: Movie)
}

class MyMovieTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieSeenButton: UIButton!
    
    //MARK: - Properties
    var delegate: MovieWasSeenDelegate?
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - Private Functions
    private func updateViews() {
        guard let movie = movie else {
            return
        }
        
        movieTitleLabel.text = movie.title
        
        if movie.hasWatched == true {
            movieSeenButton.setTitle("Watched", for: .normal)
        } else {
            movieSeenButton.setTitle("Not Watched", for: .normal)
        }
    }
    
    //MARK: - IBActions
    @IBAction func movieWasSeen(_ sender: Any) {
        guard let movie = movie else { return }
        delegate?.movieWasWatched(movie: movie)
    }
}
