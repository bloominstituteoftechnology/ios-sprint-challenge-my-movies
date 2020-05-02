//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Shawn James on 5/2/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var wasWatchedButton: UIButton!
    
    var movie: Movie?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        updateViews()
    }
    
    @IBAction func wasWatchedButton(_ sender: Any) {
        movie?.hasWatched.toggle()
        updateViews()
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        
        movieTitleLabel.text = movie.title
        wasWatchedButton.setTitle(movie.hasWatched == true ? "Watched" : "Not Watched",
                                  for: .normal)
    }
    
}
