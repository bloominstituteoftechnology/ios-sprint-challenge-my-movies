//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Jesse Ruiz on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var movieController: MovieController?
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var movieTitle: UILabel!
    
    
    // MARK: - Actions
    @IBAction func addMovie(_ sender: UIButton) {
        
        guard let movieController = movieController,
            let movie = movieRepresentation,
            let hasWatched = movie.hasWatched else { return }
        
        movieController.createMovie(with: movie.title, hasWatched: hasWatched, context: CoreDataStack.shared.mainContext)
    }
    
    // MARK: - Methods
    func updateViews() {
        
        guard let movie = movieRepresentation else { return }
        
        movieTitle.text = movie.title
    }
    

}
