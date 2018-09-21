//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Dillon McElhinney on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MovieTableViewCellDelegate: class {
    func toggleHasWatchedOn(movie: Movie)
}

class MovieTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var movie: Movie? {
        didSet{
            updateViews()
        }
    }
    
    weak var delegate: MovieTableViewCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    
    // MARK: - UI Methods
    @IBAction func toggleHasWatched(_ sender: Any) {
        guard let movie = movie else { return }
        delegate?.toggleHasWatchedOn(movie: movie)
    }
    
    // MARK: Utility Methods
    func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        watchedButton.setTitle(movie.hasWatched ? "Watched" : "Unwatched", for: .normal)
    }
    
}
