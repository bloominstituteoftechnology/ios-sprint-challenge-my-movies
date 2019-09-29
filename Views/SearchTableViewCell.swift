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

	var hasBeenAdded: Bool = false

	var movieController: MovieController?

	var movie: MovieRepresentation? {
		didSet {
			setViews()
		}
	}

	override func awakeFromNib() {
		setViews()
	}

	private func setViews() {

		titleLabel.text = movie?.title

		if hasBeenAdded == false {
			saveMovieButton.setTitle("Add Movie", for: .normal)
		} else if hasBeenAdded == true {
			saveMovieButton.setTitle("Movie Added", for: .normal)
		}
	}

	@IBAction func saveMovieButtonTapped(_ sender: UIButton) {

		hasBeenAdded = !hasBeenAdded
		
		guard let title = titleLabel.text else {return}
		movieController?.createMovie(with: title)
		CoreDataStack.shared.save()
		
	}

}
