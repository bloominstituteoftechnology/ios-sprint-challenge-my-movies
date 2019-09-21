//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Joshua Sharp on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var addMovieButton: UIButton!
    
    var title: String? {
        didSet{
            updateViews()
        }
    }
    
    var delegate: MovieSearchDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    private func updateViews() {
        guard let title = title else { return }
        titleLabel.text = title
    }
    
    @IBAction func addMovieTapped(_ sender: Any) {
        guard let title = title,
        let delegate = delegate else { return }
        delegate.addMovie (title: title)
        addMovieButton.setTitle("Added", for: .normal)
    }
    
}

