//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by David Williams on 5/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var haveWatchedButtonLabel: UIButton!
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    
    func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
    }
    

    @IBAction func haveWatched(_ sender: Any) {
        movie?.hasWatched.toggle()
    }
}
