//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Keri Levesque on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

  //MARK: Outlets
    
    @IBOutlet weak var movieTitleLabel: UILabel!

 //MARK: Properties
    var myMoviesController: MyMoviesController?
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }

    private func updateViews() {
        movieTitleLabel.text = movie?.title
    }
    
    
//MARK: Actions
    
    @IBAction func saveMovieTapped(_ sender: Any) {
        guard let movie = movie else { return }
        
        let newMovie = Movie(title: movie.title)
        myMoviesController?.sendMyMoviesToServer(movie: newMovie)
    }
    

}
