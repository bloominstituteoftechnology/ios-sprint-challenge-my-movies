//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by John McCants on 8/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MyMovieTableViewCell: UITableViewCell {
    
    var movie : Movie? {
        didSet {
            updateViews()
        }
    }
    var movieController = MovieController()

    @IBOutlet weak var movieTitle: UILabel!
    
    @IBOutlet weak var hasWatchedButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews() {
        guard let movie = movie else {return}
        movieTitle.text = movie.title
        switch movie.hasWatched {
        case false:
            hasWatchedButton.setImage(UIImage(systemName: "film"), for: .normal)
        case true:
            hasWatchedButton.setImage(UIImage(systemName: "film.fill"), for: .normal)
        }
     
    }

    @IBAction func hasWatchedTapped(_ sender: Any) {
        guard let movie = movie else {return}
        if movie.hasWatched == false {
            movie.hasWatched.toggle()
            hasWatchedButton.setImage(UIImage(systemName: "film.fill"), for: .normal)
            movieController.sendMovieToServer(movie: movie)
            try? CoreDataStack.shared.save()
        } else if movie.hasWatched == true {
            movie.hasWatched.toggle()
            hasWatchedButton.setImage(UIImage(systemName: "film"), for: .normal)
            movieController.sendMovieToServer(movie: movie)
        }
    
    }
}
