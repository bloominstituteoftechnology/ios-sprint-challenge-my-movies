//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Mark Gerrior on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    // MARK: - Properities
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watchedButtonLabel: UIButton!
    
    // MARK: - Actions
    
    @IBAction func watchedButton(_ sender: Any) {
        // FIXME: 
    }
    
    // MARK: - Private
    private func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title

        let buttonTitle = movie.hasWatched == true ? "Not Watched" : "Watched"
        watchedButtonLabel.setTitle(buttonTitle, for: .normal)
    }

}
