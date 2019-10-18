//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Isaac Lyons on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    
    var movie: Movie!
    var movieController: MovieController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews() {
        titleLabel.text = movie.title
        watchedButton.setTitle(movie.hasWatched ? "Remove" : "Mark as watched", for: .normal)
    }

    @IBAction func watchedButtonTapped(_ sender: UIButton) {
        movieController.toggleWatched(movie: movie, context: CoreDataStack.shared.mainContext)
        updateViews()
    }
}
