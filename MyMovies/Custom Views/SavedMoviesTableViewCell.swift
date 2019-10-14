//
//  SavedMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Eoin Lavery on 14/10/2019.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SavedMoviesTableViewCell: UITableViewCell {

    //MARK: - IBOUTLETS
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    //MARK: - PROPERTIES
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - PRIVATE FUNCTIONS
    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        hasWatchedButton.setTitle(movie.hasWatched ? "Seen" : "Not Seen", for: .normal)
    }
    
    //MARK: - IBACTIONS
    @IBAction func hasWatchedTapped(_ sender: Any) {
        guard let movie = movie else { return }
        SavedMoviesController.shared.toggleHasWatched(for: movie)
    }
    
}

