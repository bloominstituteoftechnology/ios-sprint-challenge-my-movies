//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Cody Morley on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MovieTableViewCell: UITableViewCell {
    //MARK: - Properties -
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var delegate: MovieSearchTableViewController?
    var movieRep: MovieRepresentation?
    
    //MARK: - Actions -
    @IBAction func addMovie(_ sender: Any) {
        guard let movieRep = movieRep else { return }
        
        let movie = Movie(movieRepresentation: movieRep)
        delegate?.movieController.saveToServer(movie: movie!)
        delegate?.movieController.saveMovies()
    }
    
    
    
}
