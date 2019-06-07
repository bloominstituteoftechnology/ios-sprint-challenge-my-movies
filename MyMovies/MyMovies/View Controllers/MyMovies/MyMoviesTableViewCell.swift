//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Kobe McKee on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    var movieController: MovieController?
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    
    
    func updateViews() {
        guard let movie = movie else { return }
        movieLabel.text = movie.title
        if movie.hasWatched {
            watchedButton.setTitle("Seen", for: .normal)
        } else {
            watchedButton.setTitle("Not Seen", for: .normal)
        }
        
        movieLabel.textColor = .white
        //watchedButton.setTitleColor(.gray, for: .normal)
        
    }
    
    
    @IBAction func toggleWatched(_ sender: Any) {
        guard let movie = movie else { return }
        movieController?.toggleWatched(movie: movie, hasWatched: movie.hasWatched)
    }
    
    

}
