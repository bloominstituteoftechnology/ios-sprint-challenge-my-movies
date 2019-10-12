//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Joel Groomer on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var lblMovieTitle: UILabel!
    @IBOutlet weak var btnWatched: UIButton!
    
    var movie: Movie? { didSet { updateViews() } }
    
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
        lblMovieTitle.text = movie.title
        btnWatched.setTitle(movie.hasWatched ? "Watched" : "Unwatched", for: .normal)
    }

}
