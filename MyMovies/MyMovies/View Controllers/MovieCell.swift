//
//  MovieCell.swift
//  MyMovies
//
//  Created by William Bundy on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class MovieCell:UITableViewCell
{
	@IBOutlet weak var watchedButton: UIButton!
	@IBOutlet weak var nameLabel: UILabel!

	var movie:Movie! {
		didSet {
			nameLabel.text = movie.title!
			watchedButton.setTitle(
				movie.hasWatched ? "Watched": "Unwatched",
				for:.normal)
		}
	}

	@IBAction func toggleWatched(_ sender: Any)
	{
		MovieController.shared.toggleWatched(movie)
		watchedButton.setTitle(
			movie.hasWatched ? "Watched": "Unwatched",
			for:.normal)
	}
}

class MovieSearchCell:UITableViewCell
{
	@IBOutlet weak var saveButton: UIButton!
	@IBOutlet weak var nameLabel: UILabel!
	var movie:MovieStub! {
		didSet {
			nameLabel.text = movie.title
			if MovieController.shared.containsMovieWithTitle(movie.title) {
				saveButton.isEnabled = false
				saveButton.setTitle("", for:.normal)
			}
		}
	}

	@IBAction func saveAction(_ sender: Any) {
		MovieController.shared.create(movie.title)
		saveButton.isEnabled = false
		saveButton.setTitle("", for:.normal)
	}
}


