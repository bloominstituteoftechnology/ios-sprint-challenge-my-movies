//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Kenneth Jones on 6/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MovieTableViewCellDelegate: class {
    func didUpdateMovie(movie: Movie)
}

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    
    weak var delegate: MovieTableViewCellDelegate?
    static let reuseIdentifier = "MyMovieCell"
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func toggleWatched(_ sender: UIButton) {
        guard let movie = movie else { return }
        
        movie.hasWatched.toggle()
        
        watchedButton.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
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
        
        watchedButton.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
    }
    
}
