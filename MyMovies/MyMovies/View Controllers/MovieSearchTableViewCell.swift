//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Hayden Hastings on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    var movieController: MovieController?
    
    var movieRep: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var movieLabel: UILabel!
    @IBAction func addMovie(_ sender: Any) {
        guard let movie = movieRep else { return }
        movieController?.createMovie(movie: movie.title, identifier: UUID())
        print("Button works")
    }
    
    func updateViews() {
        guard let movieRep = movieRep else { return }
        movieLabel.text = movieRep.title
    }

}
