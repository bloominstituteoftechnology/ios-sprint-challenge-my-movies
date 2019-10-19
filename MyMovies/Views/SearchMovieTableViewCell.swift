//
//  SearchMovieTableViewCell.swift
//  MyMovies
//
//  Created by macbook on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchMovieTableViewCell: UITableViewCell {
    
    var movieController: MovieController?
    var movieRepresentation: MovieRepresentation?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        
        guard let movieRepresentation = movieRepresentation,
            let movieController = movieController else { return }
        
        movieController.createMovie(title: movieRepresentation.title, hasWatched: false, context: CoreDataStack.shared.mainContext)
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
