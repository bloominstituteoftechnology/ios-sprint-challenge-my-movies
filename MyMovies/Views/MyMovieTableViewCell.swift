//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by John Kouris on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    var movieController: MovieController?
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }

    func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        
        if movie.hasWatched {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
        
        movieController?.put(movie: movie)
        
        do {
            let moc = CoreDataStack.shared.mainContext
            try moc.save()
        } catch {
            print("Error saving movie: \(error)")
        }
        
    }
    
    @IBAction func watchedButtonTapped(_ sender: Any) {
        movie?.hasWatched.toggle()
        updateViews()
    }
    

}
