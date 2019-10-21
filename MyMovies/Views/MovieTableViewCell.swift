//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by macbook on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    //MARK: Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    //TODO: need to implement?
    var movieController: MovieController?
    var myMoviestableVC = MyMoviesTableViewController()
    
    
    
    
    // MARK: Properties
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
     
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func hasWatchedButtonTapped(_ sender: UIButton) {
        guard let movie = movie,
            let title = movie.title else { return }
        
        self.movieController = myMoviestableVC.movieController
        
        if movie.hasWatched == false {
            movie.hasWatched.toggle()
            hasWatchedButton.setTitle("Undo", for: .normal)
            movieController?.updateMovie(movie: movie, title: title, hasWatched: movie.hasWatched, context: CoreDataStack.shared.mainContext)

        } else {
            movie.hasWatched.toggle()
            hasWatchedButton.setTitle("Watched?", for: .normal)
            movieController?.updateMovie(movie: movie, title: title, hasWatched: movie.hasWatched, context: CoreDataStack.shared.mainContext)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateViews() {
        
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        
        if movie.hasWatched == true {
            hasWatchedButton.setTitle("Undo", for: .normal)
        } else {
            hasWatchedButton.setTitle("Watched?", for: .normal)
        }
        
    }
}
