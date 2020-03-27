//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Shawn Gee on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var movieRepresentation: MovieRepresentation? { didSet { updateTitleLabel() }}
    var addMovieCallback: ((MovieRepresentation) -> ())?
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!

    
    // MARK: - IBActions
    
    @IBAction func addMovieTapped(_ sender: UIButton) {
        guard let movieRepresentation = movieRepresentation,
        let addMovieCallback = addMovieCallback else { return }
        
        addMovieCallback(movieRepresentation)
    }
    
    
    // MARK: - Private
    
    private func updateTitleLabel() {
        titleLabel.text = movieRepresentation?.title
    }

}
