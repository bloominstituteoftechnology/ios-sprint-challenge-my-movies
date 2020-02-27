//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by David Wright on 2/23/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MyMoviesTableViewCellDelegate: class {
    func hasWatchedButtonWasTapped(for movie: Movie)
}

class MyMoviesTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    weak var delegate: MyMoviesTableViewCellDelegate?
    
    // MARK: - IBOutlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    // MARK: - IBActions

    @IBAction func hasWatchedButtonTapped(_ sender: UIButton) {
        guard let movie = movie else { return }
        
        if hasWatchedButton.titleLabel?.text == "Watched" {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Watched", for: .normal)
        }
        delegate?.hasWatchedButtonWasTapped(for: movie)
    }
    
    // MARK: - UpdateViews

    private func updateViews() {
        CoreDataStack.shared.mainContext.perform {
            guard let movie = self.movie else { return }
            
            self.titleLabel.text = movie.title
                        
            let buttonTitle = movie.hasWatched ? "Watched" : "Unwatched"
            self.hasWatchedButton.setTitle(buttonTitle, for: .normal)
        }
    }
}
