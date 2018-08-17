//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Jonathan T. Miles on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBAction func save(_ sender: Any) {
        movieController?.createMovie(withTitle: titleLabel.text!)
    }
    
    //MARK: - Properties
    
    var movieController: MovieController?
    
    @IBOutlet weak var titleLabel: UILabel!
    
}
