//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Benjamin Hakes on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func addMovieButtonClicked(_ sender: Any) {
        print("button clicked")
        // TODO: Implement add movie to CoreData and Firebase
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
}
