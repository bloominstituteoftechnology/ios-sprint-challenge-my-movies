//
//  MovieSearchCell.swift
//  MyMovies
//
//  Created by Rick Wolter on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchCell: UITableViewCell {

 
    @IBOutlet weak var movieNameLabel: UILabel!
    
  @IBOutlet weak var addMovieButton: UIButton!
        
        var movieController: MovieController?
        var addMovieDelegate: AddMovieDelegate?
        var movieRepresentation: MovieRepresentation?
        
        override func awakeFromNib() {
            super.awakeFromNib()
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
        
        @IBAction func addMovieButtonTapped(_ sender: Any) {
            guard let movie = movieRepresentation else { return }
            addMovieDelegate?.addMovie(movieRepresentation: movie)
        }
        

    }
