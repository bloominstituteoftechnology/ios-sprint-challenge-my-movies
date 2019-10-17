//
//  SavedTableViewCell.swift
//  MyMovies
//
//  Created by Fabiola S on 10/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class SavedTableViewCell: UITableViewCell {
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    var delegate: SavedTableViewCellDelegate?
    
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    private func updateViews() {
        guard let movie = movie else { return }
        
        movieTitle.text = movie.title
        if movie.hasWatched == true {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
        
    }
    
    
    @IBAction func toggleHasWatched(_ sender: Any) {
        delegate?.addToWatchedList(cell: self)
    }
    
}

protocol SavedTableViewCellDelegate: class {
    func addToWatchedList(cell: SavedTableViewCell)
}
