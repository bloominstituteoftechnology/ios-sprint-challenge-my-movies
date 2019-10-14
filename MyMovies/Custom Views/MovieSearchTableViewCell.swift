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

    //MARK: - IBOUTLETS
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    //MARK: - PROPERTIES
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - PRIVATE FUNCTIONS
    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
    }
    
    //MARK: - IBACTIONS
    @IBAction func saveTapped(_ sender: Any) {
    }
    
}
