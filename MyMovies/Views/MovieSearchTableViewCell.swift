//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Nichole Davidson on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//
import Foundation
import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var movieController: MovieController?
    var movie: Movie? {
        didSet {
            updateViews() //Is this necessary??
        }
    }

    @IBOutlet weak var movieSearchTitle: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func addMovie(_ sender: UIButton) {
        guard let title = movieSearchTitle.text else { return }
        let movie = Movie(title: title, hasWatched: false)
        // TODO: - send movie to MyMoviesTableVC (and server?)
        movieController?.sendMovieToServer(movie: movie)
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
            return
        }
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        movieSearchTitle.text = movie.title
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
