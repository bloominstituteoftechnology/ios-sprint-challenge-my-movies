//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Eoin Lavery on 14/10/2019.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var movie: Movie? {
        didSet {
            guard let titleLabelText = movie?.title else { return }
            titleLabel.text = titleLabelText
        }
    }
    
    @IBAction func saveTapped(_ sender: Any) {
    }
    
}
