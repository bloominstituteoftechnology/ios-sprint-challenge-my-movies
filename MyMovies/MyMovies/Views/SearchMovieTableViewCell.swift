//
//  SearchMovieTableViewCell.swift
//  MyMovies
//
//  Created by Bradley Yin on 8/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    var movie: MovieRepresentation? {
        didSet{
            updateViews()
        }
    }
    var movieController: MovieController!
    
    func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        addMovieButton.setTitle("Add Movie", for: .normal)
    }
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        movieController.addMovie(title: movie?.title ?? "")
    }
    

}
