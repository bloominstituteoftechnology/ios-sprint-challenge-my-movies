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
    
    var movieController: MovieController?
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var isAddedButton: UIButton!

    
    // MARK: - Actions
    
    @IBAction func toggleIsAdded(_ sender: Any) {
        // Add hasWatched = false to movieRep as well as create a Movie
        
        guard let movieRep = movieRepresentation else { return }
        movieController?.addMovie(from: movieRep, context: CoreDataStack.moc)
        
        // Won't be persisted yet
        movieRepresentation?.hasWatched = false
    }
    
    
    // MARK: - Functions
    
    func updateViews() {
        guard let movieRep = movieRepresentation else { return }
        
        movieTitleLabel.text = movieRep.title
        // Once a movie has been added it should update the movieRep's has watched
        isAddedButton.titleLabel?.text = movieRep.hasWatched == nil ? "Add Movie" : "Added"
    }
}
