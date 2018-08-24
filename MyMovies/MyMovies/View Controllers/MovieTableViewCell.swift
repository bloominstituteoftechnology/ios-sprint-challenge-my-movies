//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Iyin Raphael on 8/24/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    func updateView(){
        guard let movie = movie,
            let title = movie.title else {return}
        let hasWatched = movie.hasWatched ? "Watched" : "Unwatched"
        
        titleLabel.text = title
        hasWatchedOutletButton.setTitle(hasWatched, for: .normal)
    }
    
    @IBAction func hasWatchedButton(_ sender: Any) {
        guard let movie = movie else {return}
        movieController?.update(movie: movie)
        self.reloadInputViews()
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedOutletButton: UIButton!
    var movieController: MovieController?
    var movie: Movie? {
        didSet{
            updateView()
        }
    }
}
