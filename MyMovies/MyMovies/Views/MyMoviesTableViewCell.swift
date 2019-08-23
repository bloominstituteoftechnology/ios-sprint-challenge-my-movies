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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

	@IBAction func watchButtonTapped(_ sender: UIButton) {
		
	}


}
