//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Bobby Keffury on 10/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol UpdateWatchedDelegate {
    func updateWatchedButton(with cell: MyMovieTableViewCell)
}

class MyMovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    var delegate: UpdateWatchedDelegate?
    


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
  
        movieTitleLabel.text = movie.title
        
        if movie.hasWatched {
            watchedButton.setTitle("Watched", for: .normal)
        } else {
            watchedButton.setTitle("Unwatched", for: .normal)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func watchedButtonTapped(_ sender: Any) {
        
        delegate?.updateWatchedButton(with: self)
        
    }
    
}
