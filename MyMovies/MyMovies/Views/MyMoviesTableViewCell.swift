//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Marlon Raskin on 8/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var watchButton: UIButton!

	var movieController: MovieController?
	var movie: Movie? {
		didSet {
			updateViews()
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
		watchButton.layer.cornerRadius = 6
		watchButton.layer.borderWidth = 1.5
		watchButton.layer.borderColor = UIColor.movieDBDarkBlue.cgColor
    }

	@IBAction func watchButtonTapped(_ sender: UIButton) {
		guard let movie = movie,
		 	let movieController = movieController else { return }

		let hasWatched = !movie.hasWatched
		movieController.updateHasWatched(movie: movie, hasWatched: hasWatched)
		updateViews()
	}

	func updateViews() {
		guard let movie = movie else { return }
		titleLabel.text = movie.title
		movie.hasWatched ? watchButton.setTitle("Watched", for: .normal) : watchButton.setTitle("Watch", for: .normal)
		movie.hasWatched ? watchButton.setTitleColor(.movieDBGreen, for: .normal) : watchButton.setTitleColor(.movieDBDarkBlue, for: .normal)
		if movie.hasWatched {
			watchButton.layer.borderColor = UIColor.movieDBGreen.cgColor
		} else {
			watchButton.layer.borderColor = UIColor.movieDBDarkBlue.cgColor
		}
	}
}
