//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Michael Flowers on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var watchedProperties: UIButton!
    
    @IBAction func changeWatchedButton(_ sender: UIButton) {
    }
}
