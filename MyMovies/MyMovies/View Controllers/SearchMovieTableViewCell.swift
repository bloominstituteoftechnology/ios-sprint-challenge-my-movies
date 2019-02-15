//
//  SearchMovieTableViewCell.swift
//  MyMovies
//
//  Created by Jocelyn Stuart on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchMovieTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //var movieController: MovieController?
    
    let movieController = MovieController()
    
    var movie: Movie?
    
    @IBOutlet weak var addLabel: UIButton!
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    @IBAction func addMovieTapped(_ sender: Any) {
        guard let movieTitle = movieTitleLabel.text else { return }
        
        movieController.addMovie(withTitle: movieTitle)
        print(movieTitle)
        addLabel.setTitle("Added", for: .normal)
        addLabel.tintColor = .gray
    }
    

}
