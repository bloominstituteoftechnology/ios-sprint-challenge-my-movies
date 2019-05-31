//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Hector Steven on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {


	@IBAction func unwatchedToggleButton(_ sender: Any) {
	}
	
	private func setupViews() {
		
	}
	
	@IBOutlet var titleLabel: UILabel!
	var movie: Movie? { didSet {  } }
	
	//a controller
}
