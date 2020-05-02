//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Breena Greek on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "MyMovieCell"
    var movie: Movie? {
         didSet {
             updateViews()
         }
     }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var hasWachedButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func toggleHasWatched(_ sender: Any) {
        
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
        movieTitle.text = movie?.title
       
        if movie?.hasWatched == false {
            movieTitle.text = "Unwatched"
        } else {
            movieTitle.text = "Watched"
        }
    }

}
