//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Keri Levesque on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    static let shouldShowMovieAdded = NSNotification.Name("ShouldShowMovieAdded")
}

protocol MovieSearchTableViewCellDelegate: class {
    func addMovie(cell: MovieTableViewCell, movie: MovieRepresentation)
}

class MovieTableViewCell: UITableViewCell {

  //MARK: Outlets
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
 //MARK: Properties
    static let reuseIdentifier = "MovieCell"
    var myMoviesController: MyMoviesController?
    weak var delegate: MovieSearchTableViewCellDelegate?
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }

     func updateViews() {
        movieTitleLabel.text = movieRepresentation?.title
    }
    
    
//MARK: Actions
    
    @IBAction func saveMovieTapped(_ sender: Any) {
        guard let movieRepresentation = movieRepresentation else { return }
        delegate?.addMovie(cell: self, movie: movieRepresentation)
         
        NotificationCenter.default.post(name: .shouldShowMovieAdded, object: self)
    }
    

}
