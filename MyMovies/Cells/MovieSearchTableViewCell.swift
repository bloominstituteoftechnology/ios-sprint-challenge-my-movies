//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Brian Rouse on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    // MARK: - iVars
    
    var movieController: MovieController?
    var movieRep: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - CellLifeCycle

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews() {
        guard let movie = movieRep else { return }
        movieTitleLabel.text = movie.title
        movieTitleLabel.textColor = .black
        
    }

    
    @IBAction func addMovieButtonPressed(_ sender: Any) {
        print("Pressed!")
        guard let movie = movieRep else { return }
        movieController?.createMovie(title: movie.title, identifier: UUID())
        addMovieButton.setTitle("Added!", for: .normal)
    }

}
