//
//  MyMoviesCell.swift
//  MyMovies
//
//  Created by Nonye on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesCell: UITableViewCell {
    // MARK: - PROPERTIES
    var movieController: MovieController?
    // MARK: - OUTLETS
    @IBOutlet weak var myMovieTitle: UILabel!
    @IBOutlet weak var hasWatched: UIButton!
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        myMovieTitle.text = movie.title
        
        hasWatched.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
    }
    
    
    // MARK: - ACTIONS
    @IBAction func hasWatchToggle(_ sender: UIButton) {
        guard let movie = movie else { return }
        
        movie.hasWatched.toggle()
        
        sender.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            CoreDataStack.shared.mainContext.reset()
            
        }
    }
}
