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
        print("Add movie button tapped.  The movie name is \(textLabel?.text)")
    }

    
}
