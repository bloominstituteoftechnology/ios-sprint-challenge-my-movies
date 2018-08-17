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
            updateViews()
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
        guard let movieRep = movieRepresentation else { return }
        
        movieTitleLabel.text = movieRep.title
        // Once a movie has been added it should update the movieRep's has watched
        isAddedButton.titleLabel?.text = movieRep.hasWatched == nil ? "Add Movie" : "Added"
    }
}
