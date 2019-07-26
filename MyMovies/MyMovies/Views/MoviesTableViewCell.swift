//
//  MoviesTableViewCell.swift
//  MyMovies
//
//  Created by Kat Milton on 7/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MoviesTableViewCellDelegate: class {
    func toggleHasWatched(cell: MoviesTableViewCell)
}
class MoviesTableViewCell: UITableViewCell {
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var movieController: MovieController?
    
    weak var moviesTVCD: MoviesTableViewCellDelegate?
    

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var watchedButton: UIButton!
    
    
    @IBAction func togglePressed(_ sender: UIButton) {
        moviesTVCD?.toggleHasWatched(cell: self)
    }

    
    func updateViews() {
        
        if let movie = movie {
            titleLabel.text = movie.title
            if movie.hasWatched == true {
                watchedButton.setTitle("Watched", for: .normal)
                
            } else {
                watchedButton.setTitle("Unwatched", for: .normal)
               
            }
        }
    }
    
    
    

}
