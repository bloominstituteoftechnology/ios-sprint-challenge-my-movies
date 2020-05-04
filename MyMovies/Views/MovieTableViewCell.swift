//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Marc Jacques on 5/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var movieController: MovieController?
    var searchedMovie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        updateViews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateViews() {
        guard let searchedMovie = searchedMovie else { return }
        titleLabel.text = searchedMovie.title
        
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        guard let movieController = movieController, let searchedMovie = searchedMovie else { return }
        movieController.createMovie(with: searchedMovie.title, identifier: searchedMovie.identifier ?? UUID(), hasWatched: false)
    }
}
