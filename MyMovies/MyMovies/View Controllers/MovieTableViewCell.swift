//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Daniela Parra on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell, MovieControllerProtocol {
    
    private func updateViews() {
        
        guard let movieRepresentation = movieRepresentation else { return }
        
        movieLabel.text = movieRepresentation.title
        
    }
    
    @IBAction func addMovie(_ sender: Any) {
        
        guard let movie = movieRepresentation else { return }
        print("before")
        movieController?.createMovie(title: movie.title)
        print("after")
    }
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    var movieController: MovieController?
    
    @IBOutlet weak var movieLabel: UILabel!
    
}
