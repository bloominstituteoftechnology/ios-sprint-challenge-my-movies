//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Iyin Raphael on 8/24/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit



class MovieSearchTableViewCell: UITableViewCell {
    func update(){
        guard let movieRepresentation = movieRepresentation else {return}
        titleLabel.text = movieRepresentation.title
    }
    
 
    @IBAction func addMovie(_ sender: Any) {
        guard let movieRepresentation = movieRepresentation else {return}
        moc.object
        movieController?.createMovie(movieRepresentation: movieRepresentation)
        
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    var movieController: MovieController?
    var movieRepresentation: MovieRepresentation? {
        didSet{
            update()
        }
    }
}
