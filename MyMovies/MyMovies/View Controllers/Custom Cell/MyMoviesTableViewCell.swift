//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Madison Waters on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var myMoviesListLabel: UILabel!
    @IBOutlet weak var moviesWatchedButtonTitle: UIButton!
    
    @IBAction func watchedMovieButtonToggle(_ sender: Any) {
        
        if let movie = movie {
            
            let watchedButtonTitle = movie.watched ? "Unwatched" : "Watched"
            moviesWatchedButtonTitle.setTitle(watchedButtonTitle, for: .normal)
            
            movieController.updateWatchedButton(movie: movie)
        } else {
            return
        }
    }
    
    var movie: Movie? {
        didSet{
            //updateViews()
        }
    }

    func updateViews() {
        
        
        guard let movie = movie else { return }
        
        myMoviesListLabel.text = movie.title
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var movieController = MovieController()
    
}
