//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Jeremy Taylor on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
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
        print("Add movie tapped!")
        
    }
}
