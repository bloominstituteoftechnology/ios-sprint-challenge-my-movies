//
//  MyMovieCell.swift
//  MyMovies
//
//  Created by Sergey Osipyan on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieCell: UITableViewCell {

    let movieController = MovieController()
    var movie: Movies? {
        didSet {
            updateViews()
        }
    }
    func updateViews() {
      
        guard let movie = movie else { return }
        hasWatchedButton.titleLabel!.text = "Unwatched"
        movieTitleLabel.text = movie.title
      
        timestampLabel.text = movie.timeFormatted
    }
    
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    @IBAction func hasWatchedButtonAction(_ sender: Any) {
        
        guard movie != nil else { return }
        if hasWatchedButton.titleLabel!.text == "Unwatched" {
            movieController.update(movie: movie!, title: (movie?.title)!, hasWatched: true, timestamp: Date())
           hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
            movieController.update(movie: movie!, title: (movie?.title)!, hasWatched: false, timestamp: Date())
        }
        
    }
    
   
}
