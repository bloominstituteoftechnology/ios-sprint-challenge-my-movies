//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by De MicheliStefano on 17.08.18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    
    @IBAction func toggleWatchedMovie(_ sender: Any) {
        if let movieController = movieController, let movie = movie {
            movieController.toggleWatched(for: movie)
        }
    }
    
    private func updateViews() {
        myMovieTextLabel?.text = movie?.title
        
        if let hasWatched = movie?.hasWatched {
            let buttonTitle = hasWatched ? "Not Watched" : "Watched"
            myMovieButtonLabel?.setTitle(buttonTitle, for: .normal)
        }
    }
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var movieController: MovieController?
    @IBOutlet weak var myMovieTextLabel: UILabel!
    @IBOutlet weak var myMovieButtonLabel: UIButton!
}
