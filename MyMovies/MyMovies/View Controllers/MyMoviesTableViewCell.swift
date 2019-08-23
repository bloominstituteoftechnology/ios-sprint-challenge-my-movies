//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Jake Connerly on 8/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    // MARK: - IBOutlets & Properties

    @IBOutlet weak var myMovieTitleLabel: UILabel!
    @IBOutlet weak var watchedUnwatchedButton: UIButton!
    
    let movieController = MovieController()
    
    var movie: Movie? {
        didSet {
            updateViews()
            
        }
    }
    
    // MARK: - IBActions & Methods
    
    @IBAction func watchUnwatchedButtonTapped(_ sender: UIButton) {
        guard let movie = movie,
              let title = movie.title else { return }
            movie.hasWatched.toggle()
           movieController.updateMovie(movie: movie, with: title, hasWatched: movie.hasWatched)
        updateViews()
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        myMovieTitleLabel.text = movie.title
        if movie.hasWatched {
            watchedUnwatchedButton.setTitle("Watched", for: .normal)
        } else {
            watchedUnwatchedButton.setTitle("Unwatched", for: .normal)
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
