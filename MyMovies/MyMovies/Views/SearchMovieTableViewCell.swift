//
//  SearchMovieTableViewCell.swift
//  MyMovies
//
//  Created by Michael Redig on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchMovieTableViewCell: UITableViewCell {
	
	@IBOutlet var movieTitleLabel: UILabel!
	@IBOutlet var saveMovieButton: UIButton!

	var movieController: MovieController?
	var movie: MovieRepresentation? {
		didSet {
			updateViews()
		}
	}

	private func updateViews() {
		guard let movie = movie else { return }
		movieTitleLabel.text = movie.title
		if movieController?.isMovieSaved(withTitle: movie.title) ?? false {
			saveMovieButton.setTitle("Added", for: .normal)
			saveMovieButton.isEnabled = false
		} else {
			saveMovieButton.setTitle("Add Movie", for: .normal)
			saveMovieButton.isEnabled = true
		}
	}

	@IBAction func saveMovieButtonPressed(_ sender: UIButton) {
		
	}
}
