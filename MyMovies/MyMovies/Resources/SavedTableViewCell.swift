//
//  SavedTableViewCell.swift
//  MyMovies
//
//  Created by Julian A. Fordyce on 2/22/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit


protocol SavedTableViewCellDelegate: class {
    func addToWatched(cell: SavedTableViewCell)
}

class SavedTableViewCell: UITableViewCell {
    
    private func updateViews() {
        guard let movie = movie else { return }
        
     savedTitleLabel.text = movie.title
        if movie.hasWatched == true {
            watchedButton.setTitle("Watched", for: .normal)
        } else {
            watchedButton.setTitle("Unwatched", for: .normal)
        }
    }
    
    
    @IBAction func changeWatchedStatus(_ sender: Any) {
        delegate?.addToWatched(cell: self)
    }
    
    
    
    
    // MARK: - Properties
    
    var delegate: SavedTableViewCellDelegate?

    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var savedTitleLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    
    
}
