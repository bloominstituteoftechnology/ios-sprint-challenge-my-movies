//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Taylor Lyles on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MyMovieCellDelegate {
	func watchStatusToggle(for movie: Movie)
}

class MyMovieTableViewCell: UITableViewCell {
	

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var watchedButton: UIButton!
	
	var delegate: MyMovieCellDelegate?
	var movie: Movie? {
		didSet {
			configCell()
		}
	}
	
	@IBAction func hasWatchedButtonToggled(_ sender: Any) {
		guard let movie = movie else { return }
		
		delegate?.watchStatusToggle(for: movie)
		configCell()
	}
	
	
	private func configCell() {
		guard let movie = movie else { return }
		
		titleLabel.text = movie.title
		let title = movie.hasWatched ? "Watched" : "Not Watched"
		watchedButton.setTitle(title, for: .normal)
	}

}
