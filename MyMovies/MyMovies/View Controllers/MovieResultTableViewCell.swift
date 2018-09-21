//
//  MovieResultTableViewCell.swift
//  MyMovies
//
//  Created by Dillon McElhinney on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MovieResultTableViewCellDelegate: class {
    func addMovie(movieRepresentation: MovieRepresentation)
}

class MovieResultTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    weak var delegate: MovieResultTableViewCellDelegate?
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    
    
    // MARK: - UI Methods
    @IBAction func addMovie(_ sender: Any) {
        guard let movieRepresentation = movieRepresentation else { return }
        delegate?.addMovie(movieRepresentation: movieRepresentation)
    }
    
    // MARK: Utility Methods
    private func updateViews() {
        guard let movieRepresentation = movieRepresentation else { return }
        
        titleLabel.text = movieRepresentation.title
    }
    
}
