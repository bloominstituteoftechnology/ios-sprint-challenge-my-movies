//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Nelson Gonzalez on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchTableCellDelegate: class {
    func addMovie(cell: MovieSearchTableViewCell, movie: MovieRepresentation)
}

class MovieSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var addMovieButton: UIButton!
    
   //  var myMoviesController: MyMoviesController?
   // var movie: Movie!
    weak var delegate: MovieSearchTableCellDelegate?
    var movieReprensetation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateViews() {
        guard let movie = movieReprensetation else {return}
        
        titleLabel.text = movie.title
        
        addMovieButton.isEnabled = true
        addMovieButton.setTitle("Add Movie", for: .normal)
    }
   
    @IBAction func addMoviewButtonPressed(_ sender: UIButton) {
//        guard let titleLabelText = titleLabel.text else { return }
//        myMoviesController?.createMovie(title: titleLabelText)
//        addMovieButton.backgroundColor = UIColor.lightGray
//       // addMovieButton.setTitleColor(UIColor.accentColor, for: .normal)
//        addMovieButton.setTitle("Movie Added", for: .normal)
        guard let movieRepresentation = movieReprensetation else {return}
        delegate?.addMovie(cell: self, movie: movieRepresentation)
        addMovieButton.setTitle("Saved", for: .normal)
        
        addMovieButton.isEnabled = false
    }
    
}
