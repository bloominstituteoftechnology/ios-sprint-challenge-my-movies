//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Cody Morley on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    
    static let reuseIdentifier = "MyMovieCell"
    var movie: Movie?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBAction func toggleWatched(_ sender: Any) {
        
    }
    
    
}
