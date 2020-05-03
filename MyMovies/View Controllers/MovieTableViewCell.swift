//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Claudia Contreras on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet var movieTitleLabel: UILabel!
    @IBOutlet var addMovieButton: UIButton!
    
    // MARK: - Properties
    var movieController = MovieFirebaseController()
    
    // MARK: - IBActions
    @IBAction func addMovieButtonPressed(_ sender: Any) {
        
        guard let title = movieTitleLabel.text, !title.isEmpty else { return }

        let movie = Movie(title: title)
        //Save the movie in firebase and persistence
        movieController.addMovie(movie: movie)
        do {
            try CoreDataStack.shared.mainContext.save()
            DispatchQueue.main.async {
                self.addMovieButton.isEnabled = false
            }
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
        
    }
    

}
