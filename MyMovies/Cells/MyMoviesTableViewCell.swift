//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Brian Rouse on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    // MARK: - iVars
    
    var movieController: MovieController?
    var movieRep: MovieRepresentation?
    
    // MARK: - CellLifeCycle

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
        if movie.hasWatched == true {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
    }
    
    @IBAction func hasWatchedButtonPressed(_ sender: Any) {
        guard let movie = movie else { return }
        movie.hasWatched = !movie.hasWatched
        movieController?.updateMovie(movie: movie)
    }
    
    // MARK: - Properties & Outlets
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    

}
