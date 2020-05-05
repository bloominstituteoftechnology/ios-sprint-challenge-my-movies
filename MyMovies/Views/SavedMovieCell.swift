//
//  SavedMovieCell.swift
//  MyMovies
//
//  Created by Waseem Idelbi on 5/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class SavedMovieCell: UITableViewCell {

    //MARK: - Properties and IBOutlets -
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet var movieTitleLabel: UILabel!
    @IBOutlet var hasWatchedButton: UIButton!
    
    //MARK: - Methods and IBActions -
    
    func updateViews() {
        movieTitleLabel.text = movie?.title
        if movie!.hasWatched {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
    }
    
    @IBAction func hasWatchedButtonTapped(_ sender: Any) {
        
        if movie!.hasWatched {
            movie?.hasWatched = false
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        } else {
            movie?.hasWatched = true
            hasWatchedButton.setTitle("Watched", for: .normal)
        }
        
        let movieController = MovieController()
        movieController.sendMovieToServer(movie!)
        movieController.save(context: CoreDataStack.shared.mainContext)
        
    }
    
} //End of class
