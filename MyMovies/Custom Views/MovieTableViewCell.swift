//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Ciara Beitel on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    var movieController: MovieController?
    var movie: Movie?
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    @IBOutlet weak var movieHasWatchedButton: UIButton!
    
    @IBAction func hasWatchedButtonTapped(_ sender: Any) {
        guard let movie = movie,
            let title = movie.title,
            let identifier = movie.identifier else { return }
        movieController?.updateMovie(movie: movie, title: title, identifier: identifier, hasWatched: !movie.hasWatched)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
