//
//  MyMovieCell.swift
//  MyMovies
//
//  Created by Jeffrey Santana on 8/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MyMovieCellDelegate {
	func watchStatusToggle(for movie: Movie)
}

class MyMovieCell: UITableViewCell {

	//MARK: - IBOutlets
	
	@IBOutlet weak var titleLbl: UILabel!
	@IBOutlet weak var watchedBtn: UIButton!
	
	//MARK: - Properties
	
	var delegate: MyMovieCellDelegate?
	var movie: Movie? {
		didSet {
			configCell()
		}
	}
	
	//MARK: - IBActions
	
	@IBAction func hasWatchedToggleBtn(_ sender: UIButton) {
		guard let movie = movie else { return }
		
		delegate?.watchStatusToggle(for: movie)
		configCell()
	}
	
	//MARK: - Helpers
	
	private func configCell() {
		guard let movie = movie else { return }
		
		titleLbl.text = movie.title
		let title = movie.hasWatched ? "Watched" : "UnWatched"
		watchedBtn.setTitle(title, for: .normal)
	}
}
