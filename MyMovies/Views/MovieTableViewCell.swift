//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Cody Morley on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    //MARK: - Properties -
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    static let reuseIdentifier = "MyMovieCell"
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    
    //MARK: - Actions -
    @IBAction func toggleWatched(_ sender: UIButton) {
        movie?.hasWatched.toggle()
        
        hasWatchedButton.setImage((movie?.hasWatched ?? false) ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
    }
    
    
    //MARK: - Methods -
    private func updateViews(){
        guard let movie = movie else { return }
        
        self.titleLabel.text = movie.title
    }
    
    
}
