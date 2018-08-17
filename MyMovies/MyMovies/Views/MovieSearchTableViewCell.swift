//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Linh Bouniol on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchTableViewCellDelegate {
    func saveMovie(for cell: MovieSearchTableViewCell)
}

class MovieSearchTableViewCell: UITableViewCell {
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    var delegate: MovieSearchTableViewCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var saveMovie: UIButton!
    
    @IBAction func saveMovie(_ sender: Any) {
        delegate?.saveMovie(for: self)
        
        updateViews()
    }
    
    func updateViews() {
        guard let movieRepresentation = movieRepresentation else { return }
        
        titleLabel.text = movieRepresentation.title
        
//        saveMovie.setTitle("Add Movie", for: .normal)
    }
}
