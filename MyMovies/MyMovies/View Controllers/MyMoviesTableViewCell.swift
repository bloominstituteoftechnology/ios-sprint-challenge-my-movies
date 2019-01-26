//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Ivan Caldwell on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

//protocol MovieTableViewCellDelegate {
//    func hasWatchTapped(movie: Movie)
//}


class MyMoviesTableViewCell: UITableViewCell {
    // Variables
    let movieController = MovieController()
    //var wasTapped: Bool = false
    //var delegate: MovieTableViewCellDelegate?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    
    // Outlets and Actions
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    @IBAction func hasWatchButtonTapped(_ sender: Any) {
//        print ("Helllllloooooooooo.")
//        if hasWatchedButton.titleLabel!.text == "Unwatched" {
//            movieController.updateMovie(movie: movie!, title: movieTitleLabel.text!, hasWatched: true)
//        } else {
//            movieController.updateMovie(movie: movie!, title: movieTitleLabel.text!, hasWatched: false)
//        }
//        movie.hasWatched = !movie.hasWatched
//        movieController.updateMovie(movie: movie, title: movieTitleLabel.text!, hasWatched: movie.hasWatched)
//        wasTapped = !wasTapped
//        print("hasWatch: \(wasTapped)\n")
        
        guard let movie = movie else { return }
        movie.hasWatched = !movie.hasWatched
        movieController.put(movie: movie)
        movieController.saveToPersistentStore()
        
        hasWatchedButton.setTitle(movie.hasWatched ? "Watched" : "Unwatched", for: .normal)
        print ("Hello")
    }
    
    // Functions
    func updateViews(){
        
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
//        hasWatchedButton.setTitle(movie.hasWatched ? "Watched" : "Unwatched", for: .normal)
    }
    
    
}
