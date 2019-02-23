//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Paul Yi on 2/22/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MyMoviesTableViewCellDelegate: class {
    func hasWatchedButtonAction(on cell: MyMoviesTableViewCell)
}

class MyMoviesTableViewCell: UITableViewCell {
    
    weak var delegate: MyMoviesTableViewCellDelegate?
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    @IBAction func hasWatchedButtonAction(_ sender: Any) {
        delegate?.hasWatchedButtonAction(on: self)
    }

    func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        
        if movie.hasWatched == false {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Watched", for: .normal)
        }
        
    }

}
