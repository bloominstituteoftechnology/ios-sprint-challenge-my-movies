//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Paul Yi on 2/22/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit



class MyMoviesTableViewCell: UITableViewCell {
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    @IBAction func hasWatchedButtonAction(_ sender: Any) {
        
    }

    func updateViews() {
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
