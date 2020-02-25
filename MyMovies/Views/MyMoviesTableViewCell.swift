//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Gerardo Hernandez on 2/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MyMoviesCellDelegate: class {
    func hasWatchedButtonTapped(for movie: Movie)
}

class MyMoviesTableViewCell: UITableViewCell {

   // MARK: - Properties
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    var delegate: MyMoviesCellDelegate?
    
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    
    @IBAction func hasWatchedButtonTapped(_ sender: UIButton) {
        
        guard let movie = movie else { return }
        
        if hasWatchedButton.titleLabel?.text == "Watched" {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        } else {
            hasWatchedButton.setTitle("watched", for: .normal)
        }
        delegate?.hasWatchedButtonTapped(for: movie)
    }
    
    private func updateViews() {
        CoreDataStack.shared.mainContext.perform {
            guard let movie = self.movie else { return }
            
            self.movieLabel.text = movie.title
            let buttonTitle = movie.hasWatched ? "Watched" : "Unwatched"
            self.hasWatchedButton.setTitle(buttonTitle, for: .normal)
        }
    }
        
}
