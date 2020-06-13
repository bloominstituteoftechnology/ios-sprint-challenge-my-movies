//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Clayton Watkins on 6/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    //MARK: - Properties
    var movieController = MovieFirebaseController()
    var movie: Movie?{
        didSet{
            updateViews()
        }
    }
    
    //MARK: - Private Function
    //Updating our Movie information as needed
    private func updateViews(){
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
        hasWatchedButton.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
    }
    
    //MARK: - IBAction
    // Saving our hasWatched status to CoreData + updating it on Firebase
    @IBAction func hasWatchButtonTapped(_ sender: Any) {
        movie?.hasWatched.toggle()
        updateViews()
        movieController.addMovieToFirebase(movie: movie!)
        do{
            try CoreDataStack.shared.mainContext.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
}
