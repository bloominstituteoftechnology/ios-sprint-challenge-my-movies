//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Marc Jacques on 5/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

        @IBOutlet weak var label: UILabel!
        @IBOutlet weak var watchedButton: UIButton!
        
        var movieController: MovieController?
        var movie: Movie? {
            didSet{
                updateViews()
            }
        }
        
        func updateViews() {
            guard let movie = movie else { return }
            label.text = movie.title
            if (movie.hasWatched) {
                watchedButton.setTitle("Watched", for: .normal)
            } else {
                watchedButton.setTitle("Not Watched", for: .normal)
            }
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            guard let movieController = movieController,
                let movie = movie,
                let title = movie.title else { return }
            if (selected) {
                movieController.update(movie: movie, title: title, hasWatched: !movie.hasWatched)
                if (movie.hasWatched) {
                    watchedButton.setTitle("Watched", for: .normal)
                } else {
                    watchedButton.setTitle("Not Watched", for: .normal)
                }
            }
        }
        
    }
