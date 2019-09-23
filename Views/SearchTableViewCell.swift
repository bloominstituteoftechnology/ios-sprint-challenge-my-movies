//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Percy Ngan on 9/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var saveMovieButton: UIButton!

	var movieController: MovieController?

	var movie: MovieRepresentation? {
		didSet {
			setViews()
		}
	}

	private func setViews() {

		titleLabel.text = movie?.title

		saveMovieButton.setTitle("ADD MOIVE", for: .normal)
	}

	@IBAction func saveMovieButtonTapped(_ sender: Any) {

		guard let title = titleLabel.text else {return}
		movieController?.createMovie(with: title)
		CoreDataStack.shared.save()
		
	}

}
