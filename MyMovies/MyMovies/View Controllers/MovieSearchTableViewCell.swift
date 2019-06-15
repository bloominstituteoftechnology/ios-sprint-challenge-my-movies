//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Thomas Cacciatore on 6/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit


class MovieSearchTableViewCell: UITableViewCell {

 
    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
    }
    

    
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        //when this button is clicked.
        //turn MR into a movie
        guard let movie = movie else { return }
        let selectedMovie = Movie(title: movie.title)
        movieController.put(movie: selectedMovie)
        //grab corresponding object in cell.
        //save object locally to our container
        //put object up to firebase
    }
    
    
    var movieController = MovieController()
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    
}
