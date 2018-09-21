//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Jason Modisett on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    
    // MARK:- View updater method
    private func updateViews() {
        guard let title = movieTitle else { return }
        
        titleLabel.text = title
    }

    
    // MARK:- IBActions
    @IBAction func addMovie(_ sender: Any) {
        guard let movieController = movieController,
              let title = movieTitle else { return }
        
        movieController.addMovie(with: title)
    }
    
    
    // MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK:- Properties & types
    var movieController: MovieController?
    var movieTitle: String? { didSet { updateViews() }}
}
