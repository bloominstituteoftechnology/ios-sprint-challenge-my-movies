//
//  MyMovieCell.swift
//  MyMovies
//
//  Created by Sergey Osipyan on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieCell: UITableViewCell {

    var movie: Movies? {
        didSet {
            updateViews()
        }
    }
    func updateViews() {
      
        guard let movie = movie else { return }
        
        movieTitleLabel.text = movie.title
      
        timestampLabel.text = movie.timeFormatted
    }
    
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    @IBAction func hasWatchedButtonAction(_ sender: Any) {
        
        guard let movie = movie else { return }
        if movie.hasWatched {
           hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
        
    }
    
   
}
