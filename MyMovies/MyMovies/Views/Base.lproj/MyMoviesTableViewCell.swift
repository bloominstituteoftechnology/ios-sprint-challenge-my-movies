//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Austin Cole on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func watchedNotWatchedButtonWasTapped(_ sender: Any) {
        guard let movie = movieController.getMovieFromPersistentStoreByTitle(title: myMovieTitle.text!, context: CoreDataStack.shared.mainContext) else {fatalError("Could not get movie")}
        
        switch movie.hasWatched {
        case true:
            watchedNotWatchedButton.setTitle("Not Watched", for: .normal)
            movieController.updateMovie(movie: movie, hasWatched: false, movieRepresentation: nil)
        case false:
            watchedNotWatchedButton.setTitle("Watched", for: .normal)
            movieController.updateMovie(movie: movie, hasWatched: true, movieRepresentation: nil)
        
    }
        movieController.saveToPersistentStore(context: CoreDataStack.shared.mainContext)
    }

    
    @IBOutlet weak var myMovieTitle: UILabel!
    @IBOutlet weak var watchedNotWatchedButton: UIButton!
    let movieController = MovieController()
    
}
