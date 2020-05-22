//
//  MovieSearchCell.swift
//  MyMovies
//
//  Created by Nonye on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchCell: UITableViewCell {
    
    // MARK: - OUTLETS
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
}

