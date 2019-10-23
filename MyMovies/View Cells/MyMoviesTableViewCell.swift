//
//  MoviesTableViewCell.swift
//  MyMovies
//
//  Created by Andrew Ruiz on 10/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func hasWatchedButtonTapped(_ sender: Any) {
        //hasWatchedOutlet.titleLabel?.text = "Hello"
        print("hello")
    }
    
}
