//
//  SavedMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Jocelyn Stuart on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SavedMoviesTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        
        guard let movie = movie else { return }
        
        movieTitleLabel.text = movie.title
        
        if movie.hasWatched == false {
            toggleLabel.setTitle("Unwatched", for: .normal)
        } else {
            toggleLabel.setTitle("Watched", for: .normal)
        }
    }
    
    @IBOutlet weak var toggleLabel: UIButton!
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    @IBAction func toggleWatched(_ sender: Any) {
        if movie?.hasWatched == false {
            movie?.hasWatched = true
            updateViews()
        } else {
            movie?.hasWatched = false
            updateViews()
        }
    }
    
    
    

}
