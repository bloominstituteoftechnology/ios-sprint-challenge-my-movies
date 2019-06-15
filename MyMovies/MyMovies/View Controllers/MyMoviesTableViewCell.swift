//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by John Pitts on 6/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    @IBAction func watchedButtonTapped(_ sender: Any) {
        
        delegate?.toggleFeature(for: self)
    }
    
    
    private func updateViews() {
        
        guard let movie = movie else { return }
        myMovieLabel.text = movie.title
        
        if movie.hasWatched {
            watchedButton.setTitle("watched", for: .normal)
        } else {
            watchedButton.setTitle("unwatched", for: .normal)
        }
        
        let moc = CoreDataStack.shared.mainContext
        movieController?.movie(forUUID: movie.identifier!, in: moc)
    }
    
    var movieController: MovieController?
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var delegate: MyMoviesTableViewCellDelegate?
    
    
    @IBOutlet var myMovieLabel: UILabel!
    @IBOutlet var watchedButton: UIButton!
    

}
