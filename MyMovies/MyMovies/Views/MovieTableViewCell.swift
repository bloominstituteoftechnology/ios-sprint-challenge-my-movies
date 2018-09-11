//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Jeremy Taylor on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

protocol MovieTableViewCellDelegate {
    func addMovie(cell: MovieTableViewCell)
}

class MovieTableViewCell: UITableViewCell {
    var delegate: MovieTableViewCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func addMovie(_ sender: Any) {
        delegate?.addMovie(cell: self)
        
    }
}
