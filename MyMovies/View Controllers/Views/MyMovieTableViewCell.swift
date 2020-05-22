//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Harmony Radley on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    static let reuseIdentifier = "MyMovieCell"
        
        var movie: Movie? {
            didSet {
                updateViews()
            }
        }
        
        
        // MARK: - Outlets
        
        @IBOutlet weak var movieTitleLabel: UILabel!
        @IBOutlet weak var completedButton: UIButton!
        
        // MARK: - Action
        
        @IBAction func toggleComplete(_ sender: UIButton) {
            guard let movie = movie else { return }
            
            movie.hasWatched.toggle()
            
            sender.setImage(movie.hasWatched ? UIImage(systemName: "film") : UIImage(systemName: "film.fill"), for: .normal)
            
            do {
                try CoreDataStack.shared.mainContext.save()
            } catch {
                CoreDataStack.shared.mainContext.reset()
                NSLog("Error saving managed object context (changing movie hasWatched boolean): \(error)")
            }
        }
        
        private func updateViews() {
            guard let movie = movie else { return }
            
            movieTitleLabel.text = movie.title
            completedButton.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
        }
    }

