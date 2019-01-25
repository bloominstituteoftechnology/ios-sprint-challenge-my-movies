//
//  MyMovieCell.swift
//  MyMovies
//
//  Created by Sergey Osipyan on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieCell: UITableViewCell {

   let movieController = MovieController()
    var movie: Movies? {
        didSet {
          updateViews()
        }
    }
    func updateViews() {
      
        guard let movie = movie else { return }
        let buttonTitle = movie.hasWatched ? "Watched" : "Unwatched"
        hasWatchedButton.setTitle(buttonTitle, for: .normal)
        movieTitleLabel.text = movie.title
        timestampLabel.text = movie.timeFormatted
        
        
    }
    
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    @IBAction func hasWatchedButtonAction(_ sender: Any) {
        
        guard let movie = movie else { return }
        
        movie.hasWatched = !movie.hasWatched
       movieController.saveToPersistentStore()
       movieController.put(movie: movie)
        
    
    }
}
