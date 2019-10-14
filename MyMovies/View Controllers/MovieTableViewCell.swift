//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Vici Shaweddy on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    var movie: MovieRepresentation? {
        didSet {
            self.titleLabel.text = self.movie?.title
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var movieController: MovieController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func addMoviePressed(_ sender: Any) {
        guard let movie = self.movie else { return }
        
        self.movieController?.saveMovie(movieRepresentation: movie)
    }
}
