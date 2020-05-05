//
//  SearchMovieTableViewCell.swift
//  MyMovies
//
//  Created by Juan M Mariscal on 5/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class SearchMovieTableViewCell: UITableViewCell {
    
    var movieController = MovieController()
    var movie: Movie?
    
    // MARK: IBOutlets
    @IBOutlet weak var searchedMovieLabel: UILabel!


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: IBActions
    @IBAction func addMovieButton(_ sender: Any) {
        guard let movieTitle = searchedMovieLabel.text else { return }
        let movie = Movie(identifier: UUID(),
                          title: movieTitle,
                          hasWatched: false,
                          priority: .unwatched,
                          context: CoreDataStack.shared.mainContext)
        
        movieController.movieList.append(movie)
        movieController.sendToFirebase(movie: movie) { _ in }
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
        
    }
    
    

}
