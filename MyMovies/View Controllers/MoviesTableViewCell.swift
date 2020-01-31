//
//  MoviesTableViewCell.swift
//  MyMovies
//
//  Created by Zack Larsen on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
protocol MoviesTableViewCellDelegate {
    func addMovieToList(with movie: Movie)
}

class MoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var saveMovie: UIButton!
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }

    var delegate: MoviesTableViewCellDelegate?
    
    private func updateViews() {
        guard let movie = movie else { return }
        
    }
}


@IBAction func saveMovie(_ sender: UIButton) {
    
}
