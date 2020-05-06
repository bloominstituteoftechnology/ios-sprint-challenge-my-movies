//
//  MyMoviesCell.swift
//  MyMovies
//
//  Created by Lambda_School_loaner_226 on 5/6/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MyMoviesCellDelegate: class {
    func hasBeenWatched(on cell: MyMoviesCell)
}

class MyMoviesCell: UITableViewCell {

    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    private func updateViews() {
        
        guard let movie = movie else { return }
        movieTitle.text = movie.title
        let hasWatchedButtonTitle = movie.hasWatched ? "Watched" : "Unwatched"
        hasWatchedButton.setTitle(hasWatchedButtonTitle, for: .normal)
    }
    
    var delegate: MyMoviesCellDelegate?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func hasWatchedToggle(_ sender: Any) {
        delegate?.hasBeenWatched(on: self)
    }
    
}
