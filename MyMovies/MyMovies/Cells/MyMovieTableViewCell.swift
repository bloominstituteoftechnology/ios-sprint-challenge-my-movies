//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Jonathan T. Miles on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    @IBAction func toggleHasWatched(_ sender: Any) {
        movieController?.updateToggle(for: movie!)
    }
    
    // MARK: - Properties
    
    var movieController: MovieController?
    var movie: Movie?
    
    @IBOutlet weak var titleLabel: UILabel!
    
}
