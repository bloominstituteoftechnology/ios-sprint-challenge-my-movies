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
        guard let movieRep = movie,
            let movie = Movie(movieRepresentation: movieRep)
        else {return}
        //setup button UI, gracefully inform user of change
        if movieWatchedButton.titleLabel?.text != addedText {
            movieWatchedButton.alpha = 0
            movieWatchedButton.setTitle("Added!", for: .normal) //TODO: compare to CoreData object hasWatched
            UIView.animate(withDuration: 0.5) {
                self.movieWatchedButton.alpha = 1
            }
            //save to CoreData
            movie.hasWatched = true
            CoreDataStack.shared.save()
            movieController?.saveMovie(movie: movie)
            //put to Firebase
            movieController?.put(movie: movie)
        } else {
            //TODO: Alert
        }
        
    }
    
    private let addedText = "Added!"
    private let addMovieText = "Add Movie"
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    var movieController: MovieController?
    
    func updateViews() {
        guard let movie = movie else {return}
        if movie.hasWatched ?? false {
            movieWatchedButton.setTitle(addedText, for: .normal)
        } else {
            movieWatchedButton.setTitle(addMovieText, for: .normal)
        }
        movieNameLabel.text = movie.title
    }

}
