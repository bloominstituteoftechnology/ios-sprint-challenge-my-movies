//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Conner on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
  func updateViews() {
    if let movie = movie {
      movieTitleLabel.text = movie.title
    }
  }
  
  @IBAction func saveMovie(_ sender: Any) {
    guard let movieTitle = movieTitleLabel.text else { return }
    
    movieController?.createMovieInCoreData(title: movieTitle)
    movieController?.saveToPersistentStore()
  }
  
  @IBOutlet var movieTitleLabel: UILabel!
  
  var movie: MovieRepresentation? {
    didSet {
      updateViews()
    }
  }
  var movieController: MovieController?
  
}
