//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_201 on 12/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var myMoviesController: MyMoviesController?
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let movie = movie else {return}
        
        let newMovie = Movie(title: movie.title)
        myMoviesController?.sendMyMovieToServer(movie: newMovie)
        
    }
    
    private func updateViews() {
        titleLabel.text = movie?.title
    }
}
