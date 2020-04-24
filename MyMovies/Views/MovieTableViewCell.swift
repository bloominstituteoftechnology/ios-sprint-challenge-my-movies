//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Mark Poggi on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

  static let reuseIdentifier = "MyMovieCell"
        
        @IBOutlet weak var movieTitleLabel: UILabel!
        @IBOutlet weak var watchedButton: UIButton!

        var movie: Movie? {
            didSet {
                updateViews()
            }
        }
        
        @IBAction func toggleComplete(_ sender: UIButton) {
            guard let movie = movie else { return }
            
            movie.hasWatched.toggle()
            
            sender.setTitle(movie.hasWatched ? ("Watched") : ("NotWatched"), for: .normal)
            
            do {
                try CoreDataStack.shared.mainContext.save()
            } catch {
                NSLog("Error saving managed object context: \(error)")
            }
        }
        
        // TODO: Add action for toggling complete button
        
        private func updateViews() {
            guard let movie = movie else { return }
            
            movieTitleLabel.text = movie.title
            watchedButton.setTitle(movie.hasWatched ? ("Watched") : ("NotWatched"), for: .normal)
        }
    }
