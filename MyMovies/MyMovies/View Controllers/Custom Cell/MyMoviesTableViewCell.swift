//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Madison Waters on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MyMoviesTableViewCellDelegate: class {
    func hasWatchedToggle(cell: MyMoviesTableViewCell)
}

class MyMoviesTableViewCell: UITableViewCell {

    weak var delegate: MyMoviesTableViewCellDelegate?
    
    @IBOutlet weak var myMoviesListLabel: UILabel!
    @IBOutlet weak var moviesWatchedButtonTitle: UIButton!
    
    @IBAction func watchedMovieButtonToggle(_ sender: Any) {
        delegate?.hasWatchedToggle(cell: self) 
            
    }
    
    var movie: Movie? {
        didSet{
            updateViews()
        }
    }

    func updateViews(){
        
        
        guard let movie = movie else { return }
        
        myMoviesListLabel.text = movie.title
        
        let watchedButtonTitle = movie.watched ? "Unwatched" : "Watched"
        moviesWatchedButtonTitle.setTitle(watchedButtonTitle, for: .normal)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
