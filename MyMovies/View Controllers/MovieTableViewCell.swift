//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Eoin Lavery on 17/08/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MovieTableViewCellDelegate {
    func watchedStatusChanged(for cell: MovieTableViewCell)
}

class MovieTableViewCell: UITableViewCell {

    //MARK: IBOutlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieHasWatchedButton: UIButton!
    
    //MARK: Properties
    var delegate: MovieTableViewCellDelegate?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: Private Methods
    private func updateViews() {
        guard let movie = movie else { return }
        
        movieTitleLabel.text = movie.title
        
        switch movie.hasWatched {
        case true:
            movieHasWatchedButton.setImage(UIImage(systemName: "film.fill"), for: .normal)
        case false:
            movieHasWatchedButton.setImage(UIImage(systemName: "film"), for: .normal)
        }
    }
    
    //MARK: IBActions
    
    @IBAction func watchedStatusToggle(_ sender: Any) {
        delegate?.watchedStatusChanged(for: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
