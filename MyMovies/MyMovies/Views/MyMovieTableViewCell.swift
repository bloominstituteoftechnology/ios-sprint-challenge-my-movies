//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Jeremy Taylor on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
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
