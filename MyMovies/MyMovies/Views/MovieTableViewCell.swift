//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Samantha Gatt on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var isAddedButton: UIButton!

    
    // MARK: - Actions
    
    @IBAction func toggleIsAdded(_ sender: Any) {
        
    }
    
    
    // MARK: - Functions
    
    func updateViews() {
        guard let movieRep = movieRepresentation,
            let hasWatched = movieRep.hasWatched else { return }
        
        movieTitleLabel.text = movieRep.title
        isAddedButton.titleLabel?.text = !hasWatched ? "Add Movie" : "Added"
    }
}
