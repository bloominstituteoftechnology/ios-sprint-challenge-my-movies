//
//  MovieCellTableViewCell.swift
//  MyMovies
//
//  Created by Michael Flowers on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieCellTableViewCell: UITableViewCell {

    var movie: Movie? {
          didSet {
              print("MovieTableViewCell: movie was set")
              updateViews()
          }
      }
      
      @IBOutlet weak var nameLabel: UILabel!
      @IBOutlet weak var watchedProperties: UIButton!
      
      @IBAction func changeWatchedButton(_ sender: UIButton) {
           guard let passedInMovie = movie else { print("Error passing in movie in movietableviewcell"); return }
        
          //I could make a delegate protocol to handle the toggle. I think that would be more aligned with MVC
          MyMovieController.shared.toggle(movie: passedInMovie)
            watchedProperties.setTitle(passedInMovie.hasWatched ? "Watched" : "UnWatched", for: .normal)
      }
      
      private func updateViews(){
          guard let passedInMovie = movie else { print("Error passing in movie in movietableviewcell"); return }
          nameLabel.text = passedInMovie.title
//          let buttonTitle = passedInMovie.hasWatched ? "Watched" : "UnWatched"
//          watchedProperties.setTitle(buttonTitle, for: .normal)
         watchedProperties.setTitle(passedInMovie.hasWatched ? "Watched" : "UnWatched", for: .normal)
      }
}
