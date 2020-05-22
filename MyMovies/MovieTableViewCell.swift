//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Kelson Hartle on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: - Properties
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    // MARK: - IBOutlets
    @IBOutlet weak var completedButton: UIButton!
    @IBOutlet weak var movieTitle: UILabel!
    
    private func updateViews() {
        guard let movie = movie else { return }
        
        movieTitle.text = movie.title
        completedButton.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
    }
    
    @IBAction func toggleComplete(_ sender: UIButton) {
        guard let movie = movie else { return }
        
        movie.hasWatched.toggle()
        
        sender.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            CoreDataStack.shared.mainContext.reset()
            NSLog("Error saving context (changing movie hasWatched boolean): \(error)")
        }
    }
}
