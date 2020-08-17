//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Craig Belinfante on 8/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MovieCellDelegate: class {
    func didUpdateMovie(movie: Movie)
}

class MovieTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "MyMovieCell"

    var movie: Movie? {
        didSet{
            updateViews()
        }
    }
    
    weak var delegate: MovieCellDelegate?
    
    //Outlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    //Actions
    @IBAction func toggleWatched(_ sender: UIButton) {
        guard let movie = movie else {return}
        movie.hasWatched.toggle()
        hasWatchedButton.setImage((movie.hasWatched) ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
        do {
            try CoreDataStack.shared.mainContext.save()
            delegate?.didUpdateMovie(movie: movie)
        } catch {
            NSLog("Error saving")
        }
    }
    
    
    private func updateViews() {
        guard let movie = movie else {return}
        movieTitleLabel.text = movie.title
        hasWatchedButton.setImage((movie.hasWatched) ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
    }

}
