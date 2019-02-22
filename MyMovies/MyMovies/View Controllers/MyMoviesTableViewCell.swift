//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Angel Buenrostro on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    var movieController = MovieController()
    
    var movie: Movie? {
        didSet { updateViews() }
    }
    

    @IBOutlet weak var hasWatchedButton: UIButton!
    @IBAction func hasWatchedButtonTapped(_ sender: UIButton) {
        guard let movie = movie else { fatalError("Could not get movie")}
        movieController.toggleHasWatched(movie: movie)
        updateViews()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateViews()
    }

    private func updateViews() {
        guard let movie = movie else { return }
        let newtitle = movie.hasWatched ? "Watched" : "Unwatched"
        hasWatchedButton.setTitle(newtitle, for: .normal)
    }
}
