//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Ilgar Ilyasov on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MyMovieTableViewCellDelegate: class {
    func unwatchedButtonTapped(for movie: Movie)
}

class MyMovieTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var myMovieCellDelegate: MyMovieTableViewCellDelegate?
    var movie: Movie? {
        didSet { updateViews() }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var myMovieLabel: UILabel!
    @IBOutlet weak var unwatchedButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func unwatchedButtonTapped(_ sender: Any) {
        if let movie = movie {
            myMovieCellDelegate?.unwatchedButtonTapped(for: movie)
        }
    }
    
    func updateViews() {
        if let movie = movie {
            myMovieLabel.text = movie.title
            let status = movie.hasWatched ? "watched" : "unwatched"
            unwatchedButton.setTitle(status, for: .normal)
        }
    }
}
