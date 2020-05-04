//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Matthew Martindale on 5/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var myMovieTitle: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    func updateViews() {
        if let title = movie?.title {
            myMovieTitle.text = title
        }
        
        guard let movie = movie else { return }
        let hasWatchedText = movie.hasWatched ? "Watched" : "Not Watched"
        
        hasWatchedButton.setTitle(hasWatchedText, for: .normal)
    }
    
    @IBAction func hasWatchedButtonTapped(_ sender: Any) {
        guard let movie = movie else { return }
        movie.hasWatched.toggle()
        
        let hasWatchedText = movie.hasWatched ? "Watched" : "Not Watched"
        hasWatchedButton.setTitle(hasWatchedText, for: .normal)
        
        let context = CoreDataStack.shared.mainContext
        
        do {
            try context.save()
        } catch {
            NSLog("Error saving hasWatchedButton toggle: \(error)")
            context.reset()
        }
    }
    
}
