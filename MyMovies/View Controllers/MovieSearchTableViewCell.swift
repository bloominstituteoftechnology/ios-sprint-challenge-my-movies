//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_259 on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var movieController: MovieController?
    
    // MARK: - Outlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let movieTitle = movieTitleLabel.text,
            movieTitle.isEmpty else { return }
        let movie = MovieRepresentation(title: movieTitle, identifier: UUID(), hasWatched: false)
        
    }


}
