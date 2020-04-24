//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Bhawnish Kumar on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit


class MoviesSearchTableViewCell: UITableViewCell {
    
    var movie: Movie?
    var movieController: MovieController?
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
  
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
       guard let movieRepresentation = movieRepresentation else { return }
        let movie = Movie(title: movieRepresentation.title)
        
        movieController?.sendMovieToServer(movie: movie)
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving: \(error)")
        }
        
    }
    
    private func updateViews() {
        guard let movieRepresentation = movieRepresentation else { return }
        titleLabel?.text = movieRepresentation.title
    }
   
    
}

