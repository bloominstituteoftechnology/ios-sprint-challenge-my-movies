//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Karen Rodriguez on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    
    // MARK: - Properties
    
    var movie: Movie? {
        didSet {
            updateViews()
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
    
    // MARK: - Action

    @IBAction func hasWatchedTapped(_ sender: UIButton) {
        guard let controller = movieController,
        let movie = movie else { return }
        controller.update(for: movie)
    }
    
    // MARK: - Private
    
    private func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        watchedButton.setTitle(movie.hasWatched ? "Watched" : "Not watched", for: .normal)
    }
}
