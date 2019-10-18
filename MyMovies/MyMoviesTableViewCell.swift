//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Percy Ngan on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

	@IBOutlet weak var movieLabel: UILabel!
	@IBOutlet weak var hasWatchedButton: UIButton!

	var movieController: MovieController?

	var movie: Movie?{
		didSet {
			setViews()
		}
	}

	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	private func setViews() {

		guard  let movie = movie else { return }
		movieLabel.text = movie.title

		if movie.hasWatched == true {
			hasWatchedButton.setTitle("Watched", for: .normal)
		} else if movie.hasWatched == false {
			hasWatchedButton.setTitle("Unwatched", for: .normal)
		}
	}

	@IBAction func hasWatchedButtonTapped(_ sender: UIButton) {

		guard let movie = movie else { return }

		if movie.hasWatched == false {

			movieController?.updateMovie(movie: movie, hasWatched: true)
			hasWatchedButton.setTitle("Watched", for: .normal)
		} else if movie.hasWatched == true {
			movieController?.updateMovie(movie: movie, hasWatched: false)
			hasWatchedButton.setTitle("Unwatched", for: .normal)
		}
	}
}
