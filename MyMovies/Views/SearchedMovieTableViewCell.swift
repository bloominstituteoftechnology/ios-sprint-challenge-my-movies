//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Bobby Keffury on 10/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol AddMovieDelegate {
    func addMovie(with cell: SearchedMovieTableViewCell)
}

class SearchedMovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var saveMovieButton: UIButton!
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    var delegate: AddMovieDelegate?

    
    
    
    private func updateViews() {
        
        guard let movie = movieRepresentation else { return }
        movieTitleLabel.text = movie.title

    }
    
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func saveMovieButtonTapped(_ sender: Any) {
        
        delegate?.addMovie(with: self)
        
    }

}
