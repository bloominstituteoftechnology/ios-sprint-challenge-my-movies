//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_218 on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    let movieController = MovieController()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    @IBAction func hasWatchedTapped(_ sender: Any) {
        guard let movie = movie else { return }
        movie.hasWatched = !movie.hasWatched
        movieController.put(movie: movie)
        CoreDataStack.shared.save()
        updateViews()
    }
    
    var movie: Movie? {
        didSet{
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        let buttonTitle = movie.hasWatched ? "Watched" : "Unwatched"
        hasWatchedButton.setTitle(buttonTitle, for: .normal)
    }
    
}
