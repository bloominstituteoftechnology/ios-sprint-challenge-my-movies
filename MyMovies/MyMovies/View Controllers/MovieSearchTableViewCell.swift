//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Thomas Cacciatore on 6/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MovieDelegate {
    func passMovie(movie: Movie)
}
class MovieSearchTableViewCell: UITableViewCell {

 
    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
    }
    

    
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        //when this button is clicked.
        //grab corresponding object in cell.
        //save object locally to our container
        //put object up to firebase
    }
    
    
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    
}
