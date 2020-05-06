//
//  MovieSearchCell.swift
//  MyMovies
//
//  Created by Lambda_School_loaner_226 on 5/6/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchCellDelegate: class {
    func addToMyList(from cell: MovieSearchCell)
}

class MovieSearchCell: UITableViewCell {
    
    var delegate: MovieSearchCellDelegate?

    @IBOutlet weak var movieTitle: UILabel!
    
    func updateViews() {
        guard let movieRep = movieRepresentation else { return }
        movieTitle.text = movieRep.title
    }
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func addMovieButton(_ sender: Any) {
        delegate?.addToMyList(from: self)
    }
}
