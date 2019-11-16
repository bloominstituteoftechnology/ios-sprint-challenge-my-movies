//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Niranjan Kumar on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitle: UILabel!
    
    
    var movieController: MovieController?
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let movie = movieTitle.text else { return }
        //
        
        let addedMovie = Movie(title: movie)
        movieController?.put(movie: addedMovie) // send movie to Sever + save to CoreData
        
    }

}
