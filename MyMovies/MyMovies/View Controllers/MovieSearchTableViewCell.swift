//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by jkaunert on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//


import UIKit
import CoreData

class MovieSearchTableViewCell: UITableViewCell {
    
    func updateViews(){
        guard let representation = movieRepresentation else { return }
        movieTitleLabel.text = representation.title
        
    }
    
    let myMovieController = MyMoviesController()
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    @IBAction func addMovie(_ sender: Any) {
        guard let representation = movieRepresentation else { return }
        myMovieController.create(movieRepresentation: representation)
        
        
        
    }
}
