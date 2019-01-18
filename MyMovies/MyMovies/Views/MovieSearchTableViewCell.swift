//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Austin Cole on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func addMovieButtonWasTouched(_ sender: Any) {
        movieController.createMovie(title: movieTitleLabel.text!, hasWatched: false, identifier: UUID())
        
    }
    
    //MARK: Properties
    
    let movieController = MovieController()
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
}

