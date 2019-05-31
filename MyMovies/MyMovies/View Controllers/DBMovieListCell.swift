//
//  DBMovieListCell.swift
//  MyMovies
//
//  Created by Sameera Roussi on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class DBMovieListCell: UITableViewCell {

    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        guard let selectedMovie = textLabel?.text else { return }
    }
    
    
    var moviecontroller: MovieController?
    var selectedMovie: String?
}
