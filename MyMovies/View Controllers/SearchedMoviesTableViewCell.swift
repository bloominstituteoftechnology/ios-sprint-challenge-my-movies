//
//  SearchedMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Clayton Watkins on 6/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class SearchedMoviesTableViewCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var saveMovieButton: UIButton!
    
    //MARK: - Properties
    var movieController = MovieFirebaseController()
    var movie: Movie?
    
    //MARK: - IBAction
    @IBAction func saveMovieButtonTapped(_ sender: UIButton) {
        guard let title = movieTitleLabel.text else { return }
        let movie = Movie(title: title)
        
         /*
         PERSONAL DESIGN CHOICE NOTES (Hopfully this doesn't hurt my grade):
         Decided to add the movie to firebase here instead of when the viewDisapears.
         I don't believe viewDisapears is better in this case. Unless you were to add the option
         to deselect rows before adding them to your movie list. The only choice for removal here
         is to just delete the movie from your movie list.
         */
        
        //Adding the movie to Firebase
        movieController.addMovieToFirebase(movie: movie)
        //Saving the movie to core data
        do{
            try CoreDataStack.shared.mainContext.save()
            DispatchQueue.main.async {
                self.saveMovieButton.isEnabled = false
            }
        } catch {
            print("Error saving movie \(movie): \(error)")
        }
    }
}
