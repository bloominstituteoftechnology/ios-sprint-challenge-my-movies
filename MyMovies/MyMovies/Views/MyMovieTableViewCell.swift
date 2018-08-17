//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Samantha Gatt on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    // MARK: - Actions
    
    @IBAction func toggleIsSeen(_ sender: Any) {
        
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var myMovieTitleLabel: UILabel!
    @IBOutlet weak var isSeenButton: UIButton!
    
}
