//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Sal Amer on 2/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!

    let movieController = MovieController()

    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }

    func updateViews() {
        guard let movie = movieRepresentation else { return }
        titleLbl.text = movie.title

    }

}
