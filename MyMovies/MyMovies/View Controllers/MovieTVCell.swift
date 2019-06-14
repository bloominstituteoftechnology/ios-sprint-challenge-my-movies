//
//  MovieTVCell.swift
//  MyMovies
//
//  Created by John Pitts on 6/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTVCell: UITableViewCell {

    @IBAction func addMovieButtonTapped(_ sender: Any) {
        
        guard let title = movieTitleLabel.text else {return}
        let movie = Movie(title: title) // the other attributes will be assigned default values
        //MovieController.put(movie)
        
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet var movieTitleLabel: UILabel!
}
