//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Jerrick Warren on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class MovieTableViewCell: UITableViewCell {
    
    private func updateViews(){
        guard let movieRepresentation = movieRepresentation else {return}
        
        movieLabel.text = movieRepresentation.title
        
    }
    
    
    // outlets
    @IBOutlet weak var movieLabel: UILabel!
    
    @IBAction func saveMovie(_ sender: Any) {
        guard let movie = movieRepresentation else { return }
    
        // create movie
        movieController?.createMovie(title: movie.title)
        print(movie.title, "YES ITS ADDING WHOO WHOO!")
        
    }

    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    var movieController: MovieController?
    

}
