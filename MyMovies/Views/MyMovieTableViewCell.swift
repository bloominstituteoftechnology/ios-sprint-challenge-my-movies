//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by morse on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class MyMovieTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    // MARK: - Properties
    
    var myMoviesController: MyMoviesController?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func watchedTapped(_ sender: Any) {
        movie?.hasWatched.toggle()
        if let movie = movie {
            myMoviesController?.sendMyMovieToServer(movie: movie)
            switch movie.hasWatched {
            case true:
                button.setTitle("Watched", for: .normal)
            case false: button.setTitle("Not Watched", for: .normal)
            }
        }
    }
    
    
    // MARK: - Private
    
    private func updateViews() {
        titleLabel.text = movie?.title
        guard let watched = movie?.hasWatched else { return }
        switch watched {
        case true:
            button.setTitle("Watched", for: .normal)
        case false: button.setTitle("Not Watched", for: .normal)
        }
    }

}
