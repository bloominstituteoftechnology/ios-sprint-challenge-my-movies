//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Jon Bash on 2019-11-15.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var movieRep: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    var movieController: MovieController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addMovieTapped(_ sender: UIButton) {
        addMovieFromTMDB()
    }
    
    private func updateViews() {
        titleLabel.text = movieRep?.title
    }
    
    private func addMovieFromTMDB() {
        
    }
}
