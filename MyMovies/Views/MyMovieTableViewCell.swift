//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Niranjan Kumar on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    var movieController: MovieController?
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }

    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    
    
    @IBAction func hasWatchedTapped(_ sender: Any) {
    }
    
    
    private func updateViews(){
        
    }
    

}
