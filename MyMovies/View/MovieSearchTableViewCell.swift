//
//  MovieCell.swift
//  MyMovies
//
//  Created by Nick Nguyen on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
  
  var movieRep: MovieRepresentation?
  var movieController: MovieController?
  
  @IBOutlet weak var addMovieButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
   
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
  @IBAction func addMovieTapped(_ sender: UIButton) {
    
    addMovieFromTMDB()
  }
  
  private func addMovieFromTMDB() {
    guard let movieRep = movieRep else {
      print("Cannot add movie; cell missing movieRepresentation!")
      return
    }
    movieController?.addMovieFromTMDB(movieRep: movieRep)
    addMovieButton.isEnabled = false
  }
}

