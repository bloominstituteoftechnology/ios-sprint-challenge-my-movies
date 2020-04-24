//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Shawn James on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addButtonTapped(_ sender: Any) {
        addButton.setTitle("Added!", for: .normal)
        // TODO: add to my movies here
    }
    
}
