//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_204 on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    var movie: Movie? {
        didSet{
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        let buttonTitle = movie.hasWatched ? "Watched" : "Unwatched"
        hasWatchedButton.setTitle(buttonTitle, for: .normal)
    }
}
