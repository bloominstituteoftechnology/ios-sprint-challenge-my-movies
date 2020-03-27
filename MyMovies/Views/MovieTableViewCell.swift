//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Bradley Diroff on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol AddMovieDelegate {
func movieWasAdded(_ item: MovieRepresentation)
}

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    var delegate: AddMovieDelegate?
    
    @IBAction func createMovie(_ sender: Any) {
        
        guard let movie = movie else {return}
        
        delegate?.movieWasAdded(movie)
    }
    
    func updateViews() {
        guard let movie = movie else {return}
        
        label.text = movie.title
    }

}
