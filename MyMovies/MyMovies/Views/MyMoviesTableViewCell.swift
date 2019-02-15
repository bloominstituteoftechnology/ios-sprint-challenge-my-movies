//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Nelson Gonzalez on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit


class MyMoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var basBeenWatchedButton: UIButton!
    
    
    var movies: Movie? {
        didSet {
            updateViews()
        }
    }

    var myMoviesController: MyMoviesController?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateViews() {
        guard let movies = movies else {return}
        titleLabel.text = movies.title

        if movies.hasWatched == false {
            basBeenWatchedButton.setTitle("Unwatched", for: .normal)
        } else {
            basBeenWatchedButton.setTitle("Watched", for: .normal)
        }
    }

    @IBAction func changeHasBeenWatchedPressed(_ sender: UIButton) {
      print("Touched!")
       

        guard let movies = movies else {return}
        
                if movies.hasWatched == true {
                    movies.hasWatched = false
                } else {
                    movies.hasWatched = true
                }
        
        guard let representation = movies.movieRepresentation else {fatalError("unable to get movie representation")}
        myMoviesController?.update(movie: movies, with: representation)
        
   }
    
}
