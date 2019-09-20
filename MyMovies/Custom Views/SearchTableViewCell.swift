//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Ciara Beitel on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    var movieController: MovieController?
    
    @IBOutlet weak var movieSearchTitleLabel: UILabel!
    
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        guard let movieTitle = movieSearchTitleLabel.text else { return }
        movieController?.createMovie(title: movieTitle, identifier: UUID(), hasWatched: false)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
