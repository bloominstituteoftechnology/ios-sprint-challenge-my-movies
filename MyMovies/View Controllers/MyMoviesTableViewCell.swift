//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Nathan Hedgeman on 8/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    //Properties
    @IBOutlet var myMovieTitle: UILabel!
    @IBOutlet var seenNotSeenButton: UIButton!
    var delegate: MovieTableViewCellDelegate?

    
    // Mark: - IBActions and Methods
    @IBAction func seenNotseen(_ sender: Any) {
        delegate?.toggleHasBeenSeen(for: self)
    }

}
