//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Elizabeth Wingate on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    static let shouldShowMovieAdded = NSNotification.Name("ShouldShowMovieAdded")
}

protocol MovieSearchTableViewCellDelegate: class {
    func addMovie(cell: MovieSearchTableViewCell, movie: MovieRepresentation)
}

class MovieSearchTableViewCell: UITableViewCell {
    static let reuseIdentifier = "MovieCell"
 
    weak var delegate: MovieSearchTableViewCellDelegate?
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieButtonOutlet: UIButton!
    
    @IBAction func addMovieButton(_ sender: Any) {
     guard let movieRepresentation = movieRepresentation else { return }
         delegate?.addMovie(cell: self, movie: movieRepresentation)
         //movieButtonOutlet.setTitle("Saved", for: .normal)
         //movieButtonOutlet.isEnabled = false
        
        NotificationCenter.default.post(name: .shouldShowMovieAdded, object: self)
    }
    var movieRepresentation: MovieRepresentation? {
           didSet {
               updateViews()
           }
       }
       
    func updateViews() {
           movieTitleLabel.text = movieRepresentation?.title
          // movieButtonOutlet.isEnabled = true
          // movieButtonOutlet.setTitle("Add Movie", for: .normal)
    }
}
