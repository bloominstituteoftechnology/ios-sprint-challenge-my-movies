//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_34 on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MyMovieTableViewCellDelegate: class {
    func toggleHasWatched(for cell: MyMoviesTableViewCell)
}

class MyMoviesTableViewCell: UITableViewCell {

    //MARK: - Properties
    weak var delegate: MyMovieTableViewCellDelegate?
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }

        //MARK: - Outlets
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var hasWatched: UIButton!
    
    @IBAction func hasWatched(_ sender: Any) {
        delegate?.toggleHasWatched(for: self)
    }
    
    private func updateViews() {
        guard let movieRepresentation = movieRepresentation else { return }
        
        movieNameLabel.text = movieRepresentation.title
        if movieRepresentation.hasWatched == true {
            hasWatched.setTitle("Watched", for: .normal)
        } else {
            hasWatched.setTitle("Unwatched", for: .normal)
        }
    }
}
