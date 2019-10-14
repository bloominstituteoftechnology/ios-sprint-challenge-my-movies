//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Vici Shaweddy on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    var movie: Movie? {
        didSet {
            self.titleLabel.text = movie?.title
            self.hasWatchedButton.setTitle(movie?.hasWatched == true ? "Watched" : "Unwatched", for: .normal)
        }
    }
    
    var movieController: MovieController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func togglePressed(_ sender: Any) {
        guard let movie = self.movie else { return }
        self.movieController?.toggleHasWatched(movie: movie)
    }
    
}
