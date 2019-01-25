//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Ivan Caldwell on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func addMovieButtonTapped(_ sender: Any) {
        
    }
    @IBOutlet weak var movieTitleLabel: UILabel!
}
