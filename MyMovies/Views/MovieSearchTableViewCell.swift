//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Morgan Smith on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    var myMoviesController: MyMovieController?
    var movie: MovieRepresentation? {
         didSet {
             updateViews()
         }
     }

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func addMovie(_ sender: UIButton) {
        guard let movie = movie else {return}

        let newMovie = Movie(title: movie.title)
        myMoviesController?.sendMovieToServer(movie: newMovie)
    }

    private func updateViews() {
        titleLabel.text = movie?.title
    }
 
  
}
