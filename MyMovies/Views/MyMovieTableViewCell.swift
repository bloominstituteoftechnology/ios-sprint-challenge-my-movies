//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Morgan Smith on 6/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MyMovieTableViewCellDelegate: class {
    func didUpdateMovie(movie: Movie)
}

class MyMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var watchButton: UIButton!

    var myMoviesController: MyMovieController?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }

    static let reuseIdentifier = "MyMovieCell"
    weak var delegate: MyMovieTableViewCellDelegate?

    @IBAction func toggleWatched(_ sender: Any) {
        guard let movie = movie else { return }

        movie.hasWatched.toggle()

        switch movie.hasWatched {
        case true:
            watchButton.setTitle("Watched", for: .normal)
        case false:
            watchButton.setTitle("Not Watched", for: .normal)
        }

        delegate?.didUpdateMovie(movie: movie)
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }

    }

    private func updateViews() {
        guard let movie = movie else { return }

        titleLabel.text = movie.title

        switch movie.hasWatched {
        case true:
            watchButton.setTitle("Watched", for: .normal)
        case false:
            watchButton.setTitle("Not Watched", for: .normal)
        }
    }
}
