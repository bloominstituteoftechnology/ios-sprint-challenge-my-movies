//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Dillon P on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    var movieController: MovieController?
    var movieDelegate: AddMovieDelegate?
    var movieRepresentation: MovieRepresentation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        guard let movie = movieRepresentation else { return }
        movieDelegate?.addMovie(movieRepresentation: movie)
    }
    

}
