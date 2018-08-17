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
        guard let title = titleLabel.text else { return }
        movieController?.createMovie(withTitle: title)
    }
    
    //MARK: - Properties
    
    var movieController: MovieController?
    
    @IBOutlet weak var titleLabel: UILabel!
    
}
