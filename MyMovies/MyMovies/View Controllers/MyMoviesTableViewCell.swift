//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Madison Waters on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MyMoviesWatchedButtonDelegate: class {
    func hasWatchedToggle(cell: MyMoviesTableViewCell)
}

class MyMoviesTableViewCell: UITableViewCell {

    weak var delegate: MyMoviesWatchedButtonDelegate?
    
    @IBOutlet weak var myMoviesListLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    @IBAction func hasWatchedButtonTapped(_ sender: Any) {
        
    }
    
    var movie: Movie? {
        didSet{
            updateViews()
        }
    }
    
    func updateViews(){
        
        guard let movie = movie else { return }
        myMoviesListLabel.text = movie.title
        
        let watchedButtonTitle = movie.hasWatched ? "Unwatched" : "Watched"
        hasWatchedButton.setTitle(watchedButtonTitle, for: .normal)
    }
    
}
