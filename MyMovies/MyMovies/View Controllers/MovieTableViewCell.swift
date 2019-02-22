//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Angel Buenrostro on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell{
    
    var movieController = MovieController()
    var movie: Movie? {
        didSet { updateViews() }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBAction func saveButtonTapped(_ sender: Any) {
//        guard let movie = movie else { return }
//        let newMovie = Movie(context: movieController.moc)
//        newMovie.title = self.titleLabel.text
//        newMovie.hasWatched = false
        movieController.createMovie(with: self.titleLabel.text!, identifier: UUID(), hasWatched: false)
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    private func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
    }
}
