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
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    func updateViews() {
        movieTitleLabel.text = movie?.title
    }
    
    // MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let movieTitle = movieTitleLabel.text,
            !movieTitle.isEmpty else { return }
        movieController?.createMovie(title: movieTitle, identifier: UUID(), hasWatched: false)
    }


}
