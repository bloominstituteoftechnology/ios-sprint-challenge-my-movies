//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Hector Steven on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

	@IBAction func AddMovieButton(_ sender: Any) {
		guard let movieRep = movieRep else { return }
		
		print("add \(movieRep.title)movie to firebase")
		
		
		
		
	}
	
	private func setupViews() {
	
		titleLable?.text = movieRep?.title
		
	}
	
	@IBOutlet var titleLable: UILabel!
	var movieRep: MovieRepresentation? { didSet { setupViews() } }
}
