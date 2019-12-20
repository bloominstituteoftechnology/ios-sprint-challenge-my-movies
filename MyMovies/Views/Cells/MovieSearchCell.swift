//
//  MovieSearchCell.swift
//  MyMovies
//
//  Created by Chad Rutherford on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchCell: UITableViewCell {
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    // MARK: - Outlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    weak var delegate: MovieSearchCellDelegate?
    var movieRep: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    // MARK: - Cell Configuration
    private func updateViews() {
        guard let movieRep = movieRep else { return }
        movieTitleLabel.text = movieRep.title
    }
    
    // --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    // MARK: - Actions
    @IBAction func addMovieTapped(_ sender: UIButton) {
        guard let movieRep = movieRep, let movie = Movie(movieRepresentation: movieRep) else { return }
        do {
            try CoreDataStack.shared.save()
        } catch let dataError {
            print("Error saving managed object context: \(dataError.localizedDescription)")
        }
        delegate?.didAdd(movie)
    }
}
