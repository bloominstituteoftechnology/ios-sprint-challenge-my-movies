//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Claudia Contreras on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet var movieTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - IBAction
    @IBAction func hasWatchedButtonPressed(_ sender: Any) {
    }
    
}
