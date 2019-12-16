//
//  SearchedMovieTableViewCell.swift
//  MyMovies
//
//  Created by Jessie Ann Griffin on 12/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchedMovieTableViewCell: UITableViewCell {

    var movieController: MovieController?
    
    @IBOutlet weak var titleTextLabel: UILabel!
    
    @IBAction func addMovie(_ sender: UIButton) {
        guard let title = titleTextLabel.text else { return }
        
        _ = movieController?.createMovie(with: title)
    }
}
