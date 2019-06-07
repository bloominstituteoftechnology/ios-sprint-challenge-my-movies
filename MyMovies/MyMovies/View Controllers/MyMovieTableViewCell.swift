//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Jonathan Ferrer on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func isWatchedButtonPressed(_ sender: UIButton) {
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var isWatchedButton: UIButton!

}
