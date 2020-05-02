//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Jarren Campos on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var movieContoller: MovieController?
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    @IBAction func hasWatchedButtonTapped(_ sender: Any) {
        movie?.hasWatched.toggle()
        do {
            try CoreDataStack.shared.save()
            if let movie = movie {
                movieContoller?.sendMovieToFirebase(movie: movie)
                
            }
        } catch {
            NSLog("Error saving hasWatched")
        }
        
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
        if movie.hasWatched {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Not Watched", for: .normal)
        }
    }
    
}
