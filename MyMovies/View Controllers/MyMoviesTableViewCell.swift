//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Rob Vance on 6/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    // Properties
    static let reuseIdentifier = "MyMovieCell"
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    
    //Mark: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seenOrNotButton: UIButton!
    
    
    // Mark: Actions
    @IBAction func seenOrNotTapped(_ sender: UIButton) {
        movie?.hasWatched.toggle()
        updateViews()
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        seenOrNotButton.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
