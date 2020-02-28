//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_268 on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    
    // MARK: - Properties
    var movieController: MovieController?
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Methods
    func updateViews() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    
        
        
    
    }

    // MARK: - Outlets
    @IBOutlet weak var addMovieButton: UIButton!
       
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    // MARK: - Actions
    
    
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        guard let title = movie?.title else { return }
        MovieController.shared.create(title: title)
        
        movieTitleLabel.text = movie?.title
    }
}
