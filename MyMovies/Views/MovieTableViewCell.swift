//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Stephanie Ballard on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var hasBeenWatchedButton: UIButton!
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func hasBeenWatchedButton(_ sender: UIButton) {
        movie?.hasWatched.toggle()
        updateViews()
        print("movie button tapped")
    
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func updateViews() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
        
        hasBeenWatchedButton.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
    }
}
