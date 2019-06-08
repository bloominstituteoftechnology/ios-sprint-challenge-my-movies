//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Sameera Roussi on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    // MARK: - Watched button action
    @IBAction func watchedButtonTapped(_ sender: Any) {
        guard let movie = movie else { return }
        let hasWatched = !movie.hasWatched
        watcedButton  = hasWatched ? "Watched" : "Unwatched"
        watchedButton.setTitle(watcedButton, for: .normal)
      //  movieController!.put(movie: movie)
       // moc.save()

        
        //let context = CoreDataStack.shared.mainContext
        movieController?.updateMovie(movie: movie, hasWatched: hasWatched)//, title: title, hasWatched: hasWatched)
    }
    
    // MARK: - Private functions
    private func updateViews() {
        guard let title = movie?.title,
            let hasWatched = movie?.hasWatched
        else { return }
        
        movieTitleLabel.text = title
        
        // Update the watched button title
        watcedButton  = hasWatched ? "Watched" : "Unwatched"
        watchedButton.setTitle(watcedButton, for: .normal)
    }
    
    // MARK: - Properties
    var movieController: MyMoviesController?
    var movie: Movie? { didSet {updateViews()}}
    var watcedButton: String = ""
    
    // MARK: Outlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!

}
