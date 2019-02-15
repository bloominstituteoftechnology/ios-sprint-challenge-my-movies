//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Moses Robinson on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MyMovieTableViewCellDelegate: class {
    func toggleHasWatched(for cell: MyMovieTableViewCell)
}

class MyMovieTableViewCell: UITableViewCell {
    
    @IBAction func addMovie(_ sender: Any) {
        delegate?.toggleHasWatched(for: self)
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        
        movieNameLabel.text = movie.title
        if movie.hasWatched == true {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
    }
    
    // MARK: - Properties
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    var delegate: MyMovieTableViewCellDelegate?
    
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
}
