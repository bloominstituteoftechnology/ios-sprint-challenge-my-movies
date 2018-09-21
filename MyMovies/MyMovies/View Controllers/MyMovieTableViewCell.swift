//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Moin Uddin on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MyMovieTableViewCellDelegate: class {
    func toggleMovie(movie: Movie, newHasWatched: Bool)
}
class MyMovieTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        myMovieTitleLabel.text = movie.title
        movie.hasWatched ? hasWatchedButton.setTitle("UnWatched", for: .normal) : hasWatchedButton.setTitle("Watched", for: .normal)
    }
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    var delegate: MyMovieTableViewCellDelegate?
    
    @IBOutlet weak var myMovieTitleLabel: UILabel!
    
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    @IBAction func toggleMovieWatched(_ sender: Any) {
        guard let movie = movie else { return }
        delegate?.toggleMovie(movie: movie, newHasWatched: !movie.hasWatched)
    }
    
    
}
