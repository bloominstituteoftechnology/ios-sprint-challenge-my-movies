//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Victor  on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class MovieTableViewCell: UITableViewCell, MovieProtocol {
    
    var movieController: MovieController?
    @IBOutlet weak var movieLabel: UILabel!
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews(){
        guard let movieRepresentation = movieRepresentation else {return}
        movieLabel.text = movieRepresentation.title
    }
    
    @IBAction func saveMovie(_ sender: Any) {
        guard let movie = movieRepresentation else { return }
        movieController?.createMovie(title: movie.title)
    }
}
