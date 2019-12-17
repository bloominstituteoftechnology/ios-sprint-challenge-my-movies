//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by denis cedeno on 12/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit


class SearchTableViewCell: UITableViewCell {

    var movieController: MovieController?
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    

    @IBOutlet weak var movieTitleLabel: UILabel!
    
    @IBOutlet weak var addMovieButton: UIButton!
    
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        guard let title = movie?.title else { return }
        movieController?.create(title: title)
        print("\(title)")


    }
    
    
    func updateViews() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
    }
}
