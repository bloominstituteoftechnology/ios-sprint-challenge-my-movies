//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Jesse Ruiz on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var movieController: MovieController?
    var movie: MyMovies? {
        didSet {
            updateViews()
        }
    }

    // MARK: - Outlets
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var buttonTitle: UIButton!
    
    func updateViews() {
        
        movieTitle.text = movie?.title
        
        if movie!.hasWatched {
            buttonTitle.setTitle("Watched", for: .normal)
        } else {
            buttonTitle.setTitle("Not Watched", for: .normal)
        }
    }
    
    
    // MARK: - Actions
    @IBAction func hasWatched(_ sender: UIButton) {
        
        guard let movieController = movieController,
            let movie = movie else { return }
        
        movieController.updateMovie(movie: movie, hasWatched: !movie.hasWatched, context: CoreDataStack.shared.mainContext)
        
        updateViews()
    }
}
