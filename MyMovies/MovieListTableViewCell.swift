//
//  MoveListTableViewCell.swift
//  MyMovies
//
//  Created by Enrique Gongora on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MovieListTableViewCellDelegate: class {
    func hasWatchedButtonTapped(movie: Movie)
}

class MovieListTableViewCell: UITableViewCell {
    
    //MARK: - Variables
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    weak var delegate: MovieListTableViewCellDelegate?
    
    //MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatched: UIButton!
    
    //MARK: - IBActions
    @IBAction func hasWatchedTapped(_ sender: UIButton) {
        guard let movie = movie else { return }
        if hasWatched.titleLabel?.text == "Watched" {
            hasWatched.setTitle("Unwatched", for: .normal)
        } else {
            hasWatched.setTitle("Watched", for: .normal)
        }
        delegate?.hasWatchedButtonTapped(movie: movie)
    }
    
    //MARK: - Function
    func updateViews() {
        CoreDataStack.shared.mainContext.perform {
            guard let movie = self.movie else { return }
            self.titleLabel.text = movie.title
            let buttonTitle = movie.hasWatched ? "Watched" : "Unwatched"
            self.hasWatched.setTitle(buttonTitle, for: .normal)
        }
    }
}
