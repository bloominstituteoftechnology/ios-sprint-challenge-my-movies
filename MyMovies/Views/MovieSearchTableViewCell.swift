//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Shawn James on 5/2/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    var movie: MovieRepresentation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        updateViews()
    }
    
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        // TODO: add movie to myMoviesTVC
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        
        movieTitleLabel.text = movie.title
    }

}
