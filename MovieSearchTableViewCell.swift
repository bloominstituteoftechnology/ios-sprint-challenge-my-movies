//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Mark Poggi on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var watchedMovieButton: UIButton!
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    
    // MARK: - Properties
    
    var movieController: MovieController?

    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    
    private func updateViews() {
           guard let movie = movie else { return }
           
       }
       
    
    
    @IBAction func addMovie(_ sender: UIButton) {
        guard let title = movieTitleLabel.text
            else { return }
        
        let movie = Movie(title: title, hasWatched: true)
        movieController?.sendMovieToServer(movie: movie)
        print(movie)
               
        do {
            try CoreDataStack.shared.mainContext.save()
             sender.setTitle("Added", for: .normal)
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
   
    
}
