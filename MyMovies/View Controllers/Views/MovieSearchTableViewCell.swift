//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Harmony Radley on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "MovieCell"
    
    // MARK: - Properties
    var movieController: MovieController?
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    // MARK: - Actions
    
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        guard let movieTitle = movieTitleLabel.text,
            !movieTitle.isEmpty else { return }
        
        let movie = Movie(title: movieTitle)
        movieController?.sendMovieToServer(movie: movie)
        
        do {
            try CoreDataStack.shared.mainContext.save()
            (sender as AnyObject).setTitle("Added", for: .normal)
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    func updateViews() {
        movieTitleLabel.text = movie?.title
    }
    
    
}
