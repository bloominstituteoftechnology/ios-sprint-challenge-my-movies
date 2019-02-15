//
//  MovieDisplayTableViewCell.swift
//  MyMovies
//
//  Created by Cameron Dunn on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieDisplayTableViewCell: UITableViewCell {
    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var button: UIButton!
    var movie: MovieRepresentation?

}
