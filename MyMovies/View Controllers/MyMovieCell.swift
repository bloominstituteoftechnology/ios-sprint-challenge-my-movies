//
//  MyMovieCell.swift
//  MyMovies
//
//  Created by Rick Wolter on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieCell: UITableViewCell {

        @IBOutlet weak var movieNameLabel: UILabel!
        @IBOutlet weak var hasWatchedButton: UIButton!
        
        var movie: Movie?
        var watchedStatusDelegate: WatchedDelegate?
        
        override func awakeFromNib() {
            super.awakeFromNib()
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
        
        @IBAction func hasWatchedButtonTapped(_ sender: Any) {
            guard let movie = movie else { return }
            watchedStatusDelegate?.changeWatchedStatus(movie: movie)
        }
        

    }
