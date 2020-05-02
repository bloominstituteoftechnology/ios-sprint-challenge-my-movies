//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Kevin Stewart on 2/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var movieController: MovieController?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var addMovieLabel: UIButton!
    @IBOutlet var titleLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let movieTitle = titleLabel.text,
            movieTitle.isEmpty else { return }
        movieController?.addMovie(title: movieTitle, identifier: UUID(), hasWatched: false)
    }

    func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        
    }

}
