//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Fabiola S on 10/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    var delegate: MovieSearchTableViewCellDelegate?
    
  
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    
    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        addButton.setTitle("Add Movie", for: .normal)
    }
    
    @IBAction func addMovie(_ sender: Any) {
        delegate?.addNewMovie(cell: self)
        addButton.setTitle("Added", for: .normal)
    }
    
}

protocol MovieSearchTableViewCellDelegate: class {
    func addNewMovie(cell: MovieSearchTableViewCell)
}
