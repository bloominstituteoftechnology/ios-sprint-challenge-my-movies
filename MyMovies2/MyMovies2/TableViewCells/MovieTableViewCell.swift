//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Ryan Murphy on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//


import UIKit


protocol MovieTableViewCellDelegate: class {
    func addMovie(cell: MovieTableViewCell, movie: MovieRepresentation)
}

class MovieTableViewCell: UITableViewCell {

    weak var delegate: MovieTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        movieTitleLabel.text = movieRepresentation?.title
    }

   
    

    
    @IBOutlet weak var movieTitleLabel: UILabel!
    

    @IBAction func addMovieButtonPressed(_ sender: Any) {
        guard let movieRepresentation = movieRepresentation else { return print("nothingHappeningHere")}
        delegate?.addMovie(cell: self, movie: movieRepresentation)

    }
    
        
        
    
    
 
    
    
}
