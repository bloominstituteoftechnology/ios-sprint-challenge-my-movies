//
//  SearchMovieTableViewCell.swift
//  MyMovies
//
//  Created by Hunter Oppel on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreData

protocol SearchMovieDelegate {
    func didChangeMovie() -> Void
}

class SearchMovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    var movieController: MovieController?
    var delegate: SearchMovieDelegate?
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func addMovie(_ sender: UIButton) {
        guard let movieRepresentation = movie,
            let movie = Movie(movieRepresentation: movieRepresentation) else { return }
                
        movieController?.sendMovieToServer(movie: movie)
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
        
        delegate?.didChangeMovie()
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
        
        // Check if the movie is already in Core Data
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", movie.title)
        
        do {
            let existingMovie = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
            
            if existingMovie.isEmpty {
                addMovieButton.isEnabled = true
                addMovieButton.setTitle("Add Movie", for: .normal)
            } else {
                addMovieButton.isEnabled = false
                addMovieButton.setTitle("Added", for: .normal)
            }
        } catch {
            NSLog("Failed to fetch movie: \(movie)")
        }
    }
}
