//
//  MoviesTableViewCell.swift
//  MyMovies
//
//  Created by Joseph Rogers on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblMovieTitle: UILabel!
    @IBOutlet weak var btnWatched: UIButton!
    
    var movie: Movie? { didSet { updateViews() } }
    
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
        lblMovieTitle.text = movie.title
        btnWatched.setTitle(movie.hasWatched ? "Watched" : "Unwatched", for: .normal)
    }

    @IBAction func watchedTapped(_ sender: Any) {
        guard let movie = movie else { return }
        MyMoviesController.shared.toggleSeen(movie: movie)
    }
}
