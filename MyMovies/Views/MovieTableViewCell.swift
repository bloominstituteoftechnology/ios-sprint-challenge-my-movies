//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Alex Shillingford on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatched: UIButton!
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        hasWatched.setTitle(movie.hasWatched ? "Watched" : "Unwatched", for: .normal)
    }
    
    @IBAction func hasWatchedTapped(_ sender: UIButton) {
        guard let movie = movie else { return }
        movie.hasWatched.toggle()
        updateViews()
    }
    

}
