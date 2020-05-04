//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Matthew Martindale on 5/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var movieLabel: UILabel!
    
    var movieController: MovieController? = nil
    
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        
        if let title = movieLabel.text {
            
            let myMovie = Movie(title: title)
            
            movieController?.sendMovieToServer(movie: myMovie, completion: { _ in })
            
            let context = CoreDataStack.shared.container.newBackgroundContext()
            
            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error saving Movie to context: \(error)")
                context.reset()
            }
        }
    }
}
    


