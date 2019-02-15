//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Moses Robinson on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MovieTableViewCellDelegate: class {
    func addToMyMovies(for cell: MovieTableViewCell)
}

class MovieTableViewCell: UITableViewCell {
    
    @IBAction func addMovie(_ sender: Any) {
        delegate?.addToMyMovies(for: self)
    }

    private func updateViews() {
        guard let movie = movie else { return }
        
        movieNameLabel.text = movie.title
        addButton.setTitle("Add Movie", for: .normal)
    }
    
    // MARK: - Properties
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    var delegate: MovieTableViewCellDelegate?

    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
}
