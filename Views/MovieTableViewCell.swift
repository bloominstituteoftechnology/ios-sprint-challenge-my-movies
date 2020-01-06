//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Angelique Abacajan on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Properties
    
    var myMoviesController: MyMoviesController?
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func saveTapped(_ sender: Any) {
           guard let movie = movie else { return }
           
           let newMovie = Movies(title: movie.title)
           myMoviesController?.sendMyMovieToServer(movie: newMovie)
       }
       
    // MARK: - Private
    
    private func updateViews() {
        titleLabel.text = movie?.title
    }

}
