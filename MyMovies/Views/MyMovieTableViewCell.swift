//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Jesse Ruiz on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    var movie: MyMovies? {
        didSet {
            updateViews()
        }
    }

    // MARK: - Outlets
    
    @IBOutlet weak var movieTitle: UILabel!
    
    func updateViews() {
        
        movieTitle.text = movie?.title
    }
    
    
    // MARK: - Actions
    
    @IBAction func hasWatched(_ sender: UIButton) {
        
        
    }
    

}
