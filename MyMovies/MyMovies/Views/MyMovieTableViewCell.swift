//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Conner on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
  
  func updateViews() {
    if let movie = movie {
      movieTitleLabel.text = movie.title
      
      if (movie.hasWatched) {
        hasWatched.setTitle("Watched", for: .normal)
      } else {
        hasWatched.setTitle("Not Watched", for: .normal)
      }
      
    }
  }
  
  @IBAction func toggleWatched(_ sender: Any) {
  }
  
  
  @IBOutlet var movieTitleLabel: UILabel!
  @IBOutlet var hasWatched: UIButton!
  
  var movie: Movie? {
    didSet {
      updateViews()
    }
  }
}
