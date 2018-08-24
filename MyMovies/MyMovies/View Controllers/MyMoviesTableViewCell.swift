//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Lisa Sampson on 8/24/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    @IBAction func hasWatchedButtonTapped(_ sender: Any) {
        
    }
    
    func updateViews() {
        
    }
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
}
