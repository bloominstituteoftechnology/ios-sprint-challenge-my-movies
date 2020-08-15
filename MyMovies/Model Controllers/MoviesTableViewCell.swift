//
//  MoviesTableViewCell.swift
//  MyMovies
//
//  Created by Gladymir Philippe on 8/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seenOrNotSeenButton: UIButton!
    
    static let reuseIdentifier = "MyMovieCell"
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func seenOrNotTapped(_ sender: UIButton) {
        movie?.hasWatched.toggle()
        updateViews()
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        seenOrNotSeenButton.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
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
