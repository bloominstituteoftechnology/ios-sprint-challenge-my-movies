//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Cora Jacobson on 8/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MovieCellDelegate: class {
    func didUpdateMovie(movie: Movie)
}

class MovieTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    static let reuseIdentifier = "MyMovieCell"
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    weak var delegate: MovieCellDelegate?
    
    // MARK: - IBOutlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    
    // MARK: - Actions
    
    @IBAction func toggleHasWatched(_ sender: UIButton) {
        guard let movie = movie else { return }
        movie.hasWatched.toggle()
        hasWatchedButton.setImage((movie.hasWatched) ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
        do {
            try CoreDataStack.shared.mainContext.save()
            delegate?.didUpdateMovie(movie: movie)
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        hasWatchedButton.setImage((movie.hasWatched) ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
    }

}
