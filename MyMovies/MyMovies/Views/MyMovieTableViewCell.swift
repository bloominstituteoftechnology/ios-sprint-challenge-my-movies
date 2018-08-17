//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Jeremy Taylor on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MyMovieTableViewCellDelegate {
    func toggleWatched(cell: MyMovieTableViewCell)
}


class MyMovieTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggleWatchedButton: UIButton!
    
    var delegate: MyMovieTableViewCellDelegate?
    
    
    @IBAction func toggleWatched(_ sender: UIButton) {
        
        delegate?.toggleWatched(cell: self)
        
    }
    
}
