//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Niranjan Kumar on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitle: UILabel!
    
    var movieController: MovieController?
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    
    
    
    private func updateViews() {
        
    }

}
