//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by ronald huston jr on 8/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    static let resuseIdentifier = "MyMovieCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasSeenButton: UIButton!
    
    
    var movieController: MovieController?
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }

    private func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        hasSeenButton.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
    }

    @IBAction func hasSeenButtonTapped(_ sender: Any) {
        movie?.hasWatched.toggle()
        updateViews()
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("error saving managed object context: \(error)")
        }
    }
    

}
