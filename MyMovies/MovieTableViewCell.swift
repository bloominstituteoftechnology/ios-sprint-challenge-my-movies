//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by admin on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    var movieController = MovieController()
    var movie: Movie?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func watchedButton(_ sender: UIButton) {
        
        guard let movie = movie else { return }
        
        movieController.toggleHasBeenWatched(with: movie)
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
