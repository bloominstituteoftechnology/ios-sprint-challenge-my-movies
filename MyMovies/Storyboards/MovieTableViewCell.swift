//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Elizabeth Thomas on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: - Properties
    var movie: Movie?
    var movieController: MovieController?
    
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        
        guard let title = self.textLabel?.text else { return }
        
        let movie = Movie(title: title,
                          identifier: UUID(),
                          hasWatched: false)
        movieController?.put(movie: movie, completion: { _ in })
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
}
