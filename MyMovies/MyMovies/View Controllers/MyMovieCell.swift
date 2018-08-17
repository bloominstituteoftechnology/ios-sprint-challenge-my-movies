//
//  MyMovieCell.swift
//  MyMovies
//
//  Created by Simon Elhoej Steinmejer on 17/08/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MyMovieCellDelegate: class
{
    func watchedStatusChanged(on movie: Movie, with status: Bool)
}

class MyMovieCell: UITableViewCell
{
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    weak var delegate: MyMovieCellDelegate?
    
    var movie: Movie?
    
    @IBAction func handleHasWatched(_ sender: Any)
    {
        guard let movie = movie else { return }
        let newStatus = movie.hasWatched ? false : true
        delegate?.watchedStatusChanged(on: movie, with: newStatus)
    }
}
