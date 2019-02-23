//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Paul Yi on 2/22/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchTableViewCellDelegate: class {
    func addMovieButtonAction(on cell: MovieSearchTableViewCell)
}

class MovieSearchTableViewCell: UITableViewCell {
    
    weak var delegate: MovieSearchTableViewCellDelegate?
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBAction func addButtonAction(_ sender: Any) {
        delegate?.addMovieButtonAction(on: self)
    }
    
    func updateViews() {
        guard let movie = movieRepresentation else { return }
        
        titleLabel.text = movie.title
    }
    

}
