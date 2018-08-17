//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Samantha Gatt on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: - Actions
    
    @IBAction func toggleIsAdded(_ sender: Any) {
        
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var isAddedButton: UIButton!
    
}
