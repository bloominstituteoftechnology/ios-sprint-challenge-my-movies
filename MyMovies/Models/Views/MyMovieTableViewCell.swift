//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Sal Amer on 2/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    
    // IB Outlets
    @IBOutlet weak var movieNameLbl: UILabel!
    @IBOutlet weak var watchNotWatchedBtnLbl: UIButton!
    
    
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
    
    //IB Action
    @IBAction func watchedBtnWasPressed(_ sender: UIButton) {
    }
    
    
    private func updateViews() {
        guard let movie = movie else { return }
        movieNameLbl.text = movie.title
        let buttonTitle = movie.hasWatched ? "Watched" : "Unwatched"
        watchNotWatchedBtnLbl.setTitle(buttonTitle, for: .normal)
    }

}
