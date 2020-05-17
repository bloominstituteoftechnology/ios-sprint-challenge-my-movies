//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Casualty on 10/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    
    var movie: Movie? {
        didSet {
            updateViews()
            updateLabel()
            
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
        watchedButton.setTitle(movie.hasWatched ? "Watched" : "Not Watched",
                               for: .normal)
    }
    
    func updateLabel() {
        
        if movie?.hasWatched == true {
            watchedButton.setTitleColor(.green, for: .normal)
        } else {
            watchedButton.setTitleColor(.red, for: .normal)
        }
        movieTitleLabel.textColor = .gray
    }

    @IBAction func watchedTapped(_ sender: Any) {
        guard let movie = movie else { return }
        MyMoviesController.shared.toggleSeen(movie: movie)
    }
}
