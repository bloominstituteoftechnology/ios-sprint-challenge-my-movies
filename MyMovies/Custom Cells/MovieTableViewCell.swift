//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Chris Gonzales on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    var movie: Movie?{
        didSet{
            updateViews()
        }
    }
    
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet var watchedButton: UIButton!
    
    @IBAction func watchedToggled(_ sender: UIButton){
        
    }
    
    private func updateViews(){
        guard let movie = movie else { return }
        movieLabel.text = movie.title
        if movie.hasWatched {
            watchedButton.titleLabel?.text = "Watched"
        } else {
            watchedButton.titleLabel?.text = "Unwatched"
        }
    }

}
