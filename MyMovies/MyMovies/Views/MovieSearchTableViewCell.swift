//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by De MicheliStefano on 17.08.18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBAction func addMovie(_ sender: Any) {
        if let movieController = movieController, let title = title {
            movieController.create(title: title)
        }
    }
    
    private func updateViews() {
        if let title = title {
            moveTextLabel?.text = title
        }
    }
    
    var title: String? {
        didSet {
            updateViews()
        }
    }
    var movieController: MovieController?
    
    @IBOutlet weak var moveTextLabel: UILabel!
    @IBOutlet weak var addMovieButtonLabel: UIButton!
}
