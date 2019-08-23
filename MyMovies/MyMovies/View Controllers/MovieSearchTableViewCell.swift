//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Jake Connerly on 8/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MovieSearchTableViewCell: UITableViewCell {
    
    let movieController = MovieController()
    @IBOutlet weak var addMovieButton: UIButton!
    
    // MARK: - IBOutlets & Properties
    
    @IBOutlet weak var movieTitleLabel: UILabel! {
        didSet {
            movieChecker()
        }
    }
    
    
    
    // MARK: - IBActions & Methods
    
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        guard let title = movieTitleLabel.text else { return }
        movieController.createMovie(with: title, hasWatched: false)
    }
    
    func movieChecker() {
        guard let title = movieTitleLabel.text else { return }
        if let _ = movieController.fetchMovie(with: title, context: CoreDataStack.shared.mainContext) {
            addMovieButton.setTitle("movie Added", for: .normal)
            addMovieButton.isEnabled = false
        }
    }
    
}
