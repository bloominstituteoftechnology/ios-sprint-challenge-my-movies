//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Kobe McKee on 6/7/19.
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
        movieController?.createMovie(title: movie.title, identifier: UUID(), hasWatched: false)
    }
    
    
    func updateViews() {
        guard let movieRep = movieRep else { return }
        movieLabel.text = movieRep.title
    }
    
    
}
