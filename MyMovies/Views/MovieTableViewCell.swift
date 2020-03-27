//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Shawn Gee on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    var movie: Movie? { didSet { updateViews() }}
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    

    // MARK: - IBActions
    
    @IBAction func toggleHasWatched(_ sender: UIButton) {
        movie?.hasWatched.toggle()
        updateHasWatchedButton()
    }
    
    
    // MARK: - Private
    
    private func updateViews() {
        titleLabel.text = movie?.title
        updateHasWatchedButton()
    }
    
    private func updateHasWatchedButton() {
        guard let movie = movie else { return }
        hasWatchedButton.setTitle(movie.hasWatched ? "Watched" : "Unwatched", for: .normal)
    }
}
