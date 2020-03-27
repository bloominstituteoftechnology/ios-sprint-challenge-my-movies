//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Wyatt Harrell on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        guard let movieRepresentation = movieRepresentation else { return }
        let movie = Movie(title: movieRepresentation.title)
        
        do {
            try CoreDataStack.shared.mainContext.save()
            #warning("migrate to other save function")
        } catch {
            NSLog("Error saving: \(error)")
        }
    }
    
    
    func updateViews() {
        guard let movieRepresentation = movieRepresentation else { return }
        
        titleLabel.text = movieRepresentation.title
        
    }
}
