//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Mitchell Budge on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func updateViews() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
        if movie.hasWatched == true {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
    }
    
    @IBAction func hasWatchedButtonPressed(_ sender: Any) {
        delegate?.toggleHasWatched(for: self)
    }
    
    // MARK: - Properties & Outlets
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    var delegate: MyMoviesTableViewCellDelegate?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
}

protocol MyMoviesTableViewCellDelegate: class {
    func toggleHasWatched(for cell: MyMoviesTableViewCell)
}
