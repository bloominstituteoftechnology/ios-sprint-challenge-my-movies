//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Jonathan T. Miles on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        hasWatchedOutlet.setTitle((movie.hasWatched ? "Watched" : "Unwatched"), for: .normal)
    }
    
    @IBAction func toggleHasWatched(_ sender: Any) {
        movieController?.updateToggle(for: movie!)
        updateViews()
    }
    
    // MARK: - Properties
    
    var movieController: MovieController?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedOutlet: UIButton!
    
}
