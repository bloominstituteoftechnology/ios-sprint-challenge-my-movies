//
//  AddedMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Bhawnish Kumar on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
protocol AddedMoviesTableViewCellDelegate {
    func itHasWatched(to cell: AddedMoviesTableViewCell)
}
class AddedMoviesTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var movieWatchedButton: UIButton!
    
    var delegate: AddedMoviesTableViewCellDelegate?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    private func updateViews() {
           if let movie = movie {
               titleLabel.text = movie.title
               watchedButtonAction(movie)
           }
       }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

     
    }
    @IBAction func watchedButtonAction(_ sender: Any) {
        guard let movieWatched = movie?.hasWatched else { return }
        if movieWatched {
            movieWatchedButton.setTitle("Watched", for: .normal)
        } else {
            movieWatchedButton.setTitle("Unwatched", for: .normal)
        }

    }
    
}
