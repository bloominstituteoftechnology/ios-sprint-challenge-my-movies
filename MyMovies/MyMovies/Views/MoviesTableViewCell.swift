//
//  MoviesTableViewCell.swift
//  MyMovies
//
//  Created by Kat Milton on 7/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MoviesTableViewCell: UITableViewCell {
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var watchedButton: UIButton!
    
    
    @IBAction func movieWatchedPressed(_ sender: UIButton) {
        guard let movie = movie else { return }
        
        movie.hasWatched.toggle()
        
        
    }
    
    func updateViews() {
        watchedButton.setTitle("Unwatched", for: [])
        if let movie = movie {
            titleLabel.text = movie.title
            if movie.hasWatched == true {
                watchedButton.titleLabel?.text = "Unwatched"
            } else {
                watchedButton.titleLabel?.text = "Watched"
            }
        }
    }

}
