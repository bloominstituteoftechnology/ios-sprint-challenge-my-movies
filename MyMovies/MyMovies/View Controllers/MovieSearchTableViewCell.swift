//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Ivan Caldwell on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    let movieController = MovieController()
    var movie: Movie?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func addMovieButtonTapped(_ sender: Any) {
        movieController.createMovie(title: movieTitleLabel.text!, hasWatched: false, identifier: UUID())
    }
    
    @IBOutlet weak var movieTitleLabel: UILabel!
}
