//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Jon Bash on 2019-11-15.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    var movieRep: MovieRepresentation?
    var movieController: MovieController?
    
    @IBOutlet weak var addMovieButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addMovieTapped(_ sender: UIButton) {
        addMovieFromTMDB()
    }
    
    private func addMovieFromTMDB() {
        guard let movieRep = movieRep else {
            print("Cannot add movie; cell missing movieRepresentation!")
            return
        }
        movieController?.addMovieFromTMDB(movieRep: movieRep)
    }
}
