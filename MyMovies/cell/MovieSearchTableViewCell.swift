//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Lydia Zhang on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit


class MovieSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitle: UILabel!
    var movieController: MovieController?
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateView()
        }
    }
    
    private func updateView() {
        guard let movieRepresentation = movieRepresentation else {return}
        movieTitle.text = movieRepresentation.title
    }
    
    @IBAction func addMovie(_ sender: Any) {
        guard let movieRepresentation = movieRepresentation,
            let movie = Movie(movieRepresentation: movieRepresentation) else {return}
        movieController?.put(movie: movie)
    }

}
