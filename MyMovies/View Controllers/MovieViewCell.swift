//
//  MovieViewCell.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_218 on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    var movieRepresentation: MovieRepresentation? {
        didSet{
            updateViews()
        }
    }

    private func updateViews() {
        guard let movie = movieRepresentation else { return }
        titleLabel.text = movie.title
    }
}
