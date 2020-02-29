//
//  MovieCell.swift
//  MyMovies
//
//  Created by Nick Nguyen on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol ClouldMovieCellDelegate: AnyObject {
    func didAddMovie(movie:MovieRepresentation)
}

class CloudMovieCell: UITableViewCell {
    
    weak var delegate: ClouldMovieCellDelegate?
    
    // MARK: - Properties
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        if let movie = movie {
            movieTitle.text = movie.title
            
        }
    }
    
    
    // MARK : - IBOutlets
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var movieTitle: UILabel!
    
    
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        
        if let movie = movie {
            let newMovie =  MovieRepresentation(title: movie.title, identifier: movie.identifier ?? UUID(), hasWatched: true)
         
               delegate?.didAddMovie(movie: newMovie)
        }
     
    }
    
    
}

