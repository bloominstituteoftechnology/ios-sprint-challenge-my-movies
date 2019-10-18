//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Gi Pyo Kim on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    var movieController: MovieController?
    var movie: Movie? {
        didSet{
            updateViews()
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
    
    func updateViews() {
        titleLabel.text = movie?.title
        if movie!.hasWatched {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
    }
    
    @IBAction func hasWatchedTabbed(_ sender: Any) {
        guard let movieController = movieController, let movie = movie else { return }
        
        movieController.updateMovie(movie: movie, hasWatched: !movie.hasWatched, context: CoreDataStack.shared.mainContext)
        updateViews()
    }
    
}
