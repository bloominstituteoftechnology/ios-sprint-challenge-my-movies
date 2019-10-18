//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by admin on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wasWatchedButton: UIButton!
    
    
    var movieController = MovieController()
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        
        if movie.hasWatched == false {
            wasWatchedButton.setTitle("Unwatched", for: .normal)
        } else if movie.hasWatched == true {
            wasWatchedButton.setTitle("Watched", for: .normal)
        }
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateViews()
    }
    
    @IBAction func watchedButton(_ sender: UIButton) {
        
        guard let movie = movie,
            let title = movie.title else { return }
        
        if movie.hasWatched == false {
            movieController.updateMovie(movie: movie, with: title, hasWatched: true, context: CoreDataStack.shared.mainContext)
            wasWatchedButton.setTitle("Watched", for: .normal)
        } else if movie.hasWatched == true {
            movieController.updateMovie(movie: movie, with: title, hasWatched: false, context: CoreDataStack.shared.mainContext)
        }
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
