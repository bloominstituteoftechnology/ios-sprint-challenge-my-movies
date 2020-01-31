//
//  APIMovieTableViewCell.swift
//  MyMovies
//
//  Created by Kenny on 1/31/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class APIMovieTableViewCell: UITableViewCell {
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieWatchedButton: UIButton!
    
    @IBAction func movieWatchedButtonWasTapped(_ sender: Any) {
        guard let movie = movie else {return}
        //save to CoreData if not watched
        movie.hasWatched = true
        CoreDataStack.shared.save()
        movieController?.saveMovie(movie: movie)
        //delete from CoreData if watched
    }
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    var movieController: MovieController?
    
    func updateViews() {
        guard let movie = movie else {return}
        if movie.hasWatched {
            movieWatchedButton.setTitle("Watched", for: .normal)
        } else {
            movieWatchedButton.setTitle("Add Movie", for: .normal)
        }
        movieNameLabel.text = movie.title
    }

}
