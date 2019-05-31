//
//  SavedMovieTableViewCell.swift
//  MyMovies
//
//  Created by Michael Redig on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SavedMovieTableViewCell: UITableViewCell {

	@IBOutlet var movieTitle: UILabel!
	@IBOutlet var watchedIndicator: UISwitch!


	var movieController: MovieController?
	var movie: Movie? {
		didSet {
			updateViews()
		}
	}

	private func updateViews() {
		guard let movie = movieController?.get(movie: movie, fromContext: CoreDataStack.shared.mainContext) else { return }
		movieTitle.text = movie.title
		watchedIndicator.isOn = movie.hasWatched
	}

	@IBAction func watchedIndicatorToggled(_ sender: UISwitch) {
		guard let movie = movie else { return }
		movieController?.update(watched: sender.isOn, onMovie: movie, onContext: CoreDataStack.shared.mainContext)
	}
}
