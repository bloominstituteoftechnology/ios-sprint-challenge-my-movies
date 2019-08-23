//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Jake Connerly on 8/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    // MARK: - IBOutlets & Properties

    @IBOutlet weak var myMovieTitleLabel: UILabel!
    @IBOutlet weak var watchedUnwatchedButton: UIButton!
    
    // MARK: - IBActions & Methods
    @IBAction func watchUnwatchedButtonTapped(_ sender: UIButton) {
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
