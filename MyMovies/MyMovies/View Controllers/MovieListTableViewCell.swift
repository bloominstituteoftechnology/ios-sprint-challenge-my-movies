//
//  MovieListTableViewCell.swift
//  MyMovies
//
//  Created by Sameera Roussi on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieListTableViewCell: UITableViewCell {

    // MARK: - Actions
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        // Get the movie title and create the movie
        guard let title = textLabel?.text else { return }
   //     movieController.createMovie(title: title)
        
        // Change the Add movie button title and disable it.
        addMoviebuttonOutlet.setTitle("Movie Added", for: .normal)
        addMoviebuttonOutlet.isEnabled = false
    }

    // MARK: - Properties
    let movieController = MyMoviesController()
    @IBOutlet weak var addMoviebuttonOutlet: UIButton!
}
