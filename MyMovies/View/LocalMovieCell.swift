//
//  LocalMovieCell.swift
//  MyMovies
//
//  Created by Nick Nguyen on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol LocalMovieCellDelegate: AnyObject {
    func didUpdateStatusForMovie(movie: Movie)
}

class LocalMovieCell: UITableViewCell {

    
  
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var movieTitle: UILabel!
    
      // MARK: - Properties
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    
    
    weak var delegateTwo: LocalMovieCellDelegate?
    
    
    
    
    private func updateViews() {
        if let movie = movie {
            movieTitle.text = movie.title
            addButton.setTitle(movie.hasWatched == false ? "Unwatched" : "Watched", for: .normal)
        }
    }
    
    
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        if let movie = movie {
            movie.hasWatched.toggle()
            delegateTwo?.didUpdateStatusForMovie(movie: movie)
        }
       
    }
    
    
    
    
    
    
}
