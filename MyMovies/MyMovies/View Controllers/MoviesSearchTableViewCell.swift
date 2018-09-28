//
//  MoviesSearchTableViewCell.swift
//  MyMovies
//
//  Created by Scott Bennett on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MoviesSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    var movieController: MovieController?
    
    func updateViews() {
        guard let movieRepresentation = movieRepresentation else { return }
        titleLabel.text = movieRepresentation.title
    }

    @IBAction func saveButton(_ sender: Any) {
        print("Save \(movieRepresentation!.title)")
        
        guard let movie = movieRepresentation else { return }
        
        movieController?.create(title: movie.title)
        
    }
    
}
