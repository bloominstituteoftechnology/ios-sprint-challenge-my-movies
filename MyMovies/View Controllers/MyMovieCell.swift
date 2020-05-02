//
//  MyMovieCell.swift
//  MyMovies
//
//  Created by Chad Parker on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieCell: UITableViewCell {
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func updateViews() {
        guard let movie = movie else { fatalError() }
        
        movieTitleLabel.text = movie.title
        let buttonString = movie.hasWatched ? "Watched" : "Unwatched"
        hasWatchedButton.setTitle(buttonString, for: .normal)
    }

    @IBAction func toggleHasWatched(_ sender: Any) {
        guard let movie = movie else { fatalError() }
        
        movie.hasWatched.toggle()
        
        let movieController = MovieController()
        movieController.put(movie: movie, completion: { _ in })
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
}
