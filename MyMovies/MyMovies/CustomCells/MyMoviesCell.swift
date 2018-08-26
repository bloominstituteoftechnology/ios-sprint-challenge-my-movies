//
//  MyMoviesCell.swift
//  MyMovies
//
//  Created by Carolyn Lea on 8/25/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    
    weak var delegate: MyMoviesCellDelegate?
    var movie: Movie?
    {
        didSet
        {
            updateViews()
        }
    }
    
    
    @IBAction func toggleWatchedMovieButton(_ sender: Any)
    {
        delegate?.toggleWatchedMovie(cell: self)
    }
    
    func updateViews()
    {
        guard let movie = movie else {return}
        titleLabel.text = movie.title
        
        guard let checkedButtonImage: UIImage = UIImage(named: "checked"),
            let uncheckedButtonImage: UIImage = UIImage(named: "unchecked") else {return}
        
        if movie.hasWatched
        {
            watchedButton.setImage(checkedButtonImage, for: .normal)
        }
        else
        {
            watchedButton.setImage(uncheckedButtonImage, for: .normal)
        }
//        if let movie = movie
//        {
//            titleLabel.text = movie.title
//
//            if (movie.hasWatched)
//            {
//                watchedButton.setTitle("Unwatch", for: .normal)
//                watchedButton.setTitleColor(UIColor.lightGray, for: .normal)
//            }
//            else
//            {
//                watchedButton.setTitle("Watched", for: .normal)
//                watchedButton.setTitleColor(UIColor.blue, for: .normal)
//            }
//        }
    }
}
