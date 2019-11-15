//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Dennis Rudolph on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var myMovieTitleLabel: UILabel!
    @IBOutlet weak var myMovieWatchedButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func watchedButtonTapped(_ sender: UIButton) {
    }
    
}
