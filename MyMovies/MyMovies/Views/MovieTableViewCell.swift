//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_34 on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MovieTableViewCellDelegate: class {
    func addMovie(for cell: MovieTableViewCell)
}

class MovieTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    weak var delegate: MovieTableViewCellDelegate?
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - Outlets
    @IBOutlet weak var addMovie: UIButton!
    @IBOutlet weak var movieLabel: UILabel!
    @IBAction func addMovie(_ sender: Any) {
        delegate?.addMovie(for: self)
        addMovie.setTitle("Added", for: .normal)
    }
        
    private func updateViews() {
        guard let movieRepresentation = movieRepresentation else { return }
        
        movieLabel.text = movieRepresentation.title
        addMovie.setTitle("Add Movie", for: .normal)
        
    }
}
