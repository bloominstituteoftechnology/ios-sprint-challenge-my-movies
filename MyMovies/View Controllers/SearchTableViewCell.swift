//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Kevin Stewart on 2/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MovieAddedDelegate {
    func movieWasAdded(movie: MovieRepresentation)
}

class SearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var movieController = MovieController()
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    var delegate: MovieAddedDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var addMovieLabel: UIButton!
    @IBOutlet var titleLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let movieRep = movieRepresentation else { return}
        movieController.addMovie(title: movieRep.title)
        print("\(movieRep.title)")
        
    }

    func updateViews() {
        guard let movie = movieRepresentation else { return }
        titleLabel.text = movie.title
        
    }

}
