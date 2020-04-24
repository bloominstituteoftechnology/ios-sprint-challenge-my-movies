//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Dahna on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var watchedMovieButton: UIButton!
    
    @IBAction func toggleWatched(_ sender: Any) {
        
        guard let movie = movie else { return }
        
        movie.hasWatched.toggle()
        
        if movie.hasWatched {
            watchedMovieButton.setTitle("Seen", for: .normal)
        } else {
            watchedMovieButton.setTitle("Not Seen", for: .normal)
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        
        movieTitleLabel.text = movie.title
        
        if movie.hasWatched {
            watchedMovieButton.setTitle("Seen", for: .normal)
        } else {
            watchedMovieButton.setTitle("Not Seen", for: .normal)
        }
    }
}
