//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Claudia Contreras on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet var movieTitleLabel: UILabel!
    @IBOutlet var hasWatchedButton: UIButton!
    
    
    //MARK: Properties
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var movieController = MovieFirebaseController()
    
    // MARK: - Functions
    
    func updateViews() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
        
        if movie.hasWatched {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Not Watched", for: .normal)
        }
    }

    // MARK: - IBAction
    @IBAction func hasWatchedButtonPressed(_ sender: Any) {
        movie?.hasWatched.toggle()
        
        updateViews()
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
}
