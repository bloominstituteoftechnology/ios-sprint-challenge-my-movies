//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Josh Kocsis on 6/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MovieTableViewCellDelegate: class {
    func didUpdateMovie(movie: Movie)
}

class MovieTableViewCell: UITableViewCell {
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!

    weak var delegate: MovieTableViewCellDelegate?
    static let reuseIdentifier = "MyMovieCell"

    var movie: Movie? {
        didSet {
            updateViews()
        }
    }

    @IBAction func hasWatchedButtonTapped(_ sender: UIButton) {
        guard let movie = movie else { return }

        movie.hasWatched.toggle()

        hasWatchedButton.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
        delegate?.didUpdateMovie(movie: movie)

        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }

    private func updateViews() {
        guard let movie = movie else { return }

        movieTitleLabel.text = movie.title
        hasWatchedButton.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
    }

}
