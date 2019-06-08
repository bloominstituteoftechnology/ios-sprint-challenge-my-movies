//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Alex on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    // MARK: - Constants
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet var movieLbl: UILabel!
    @IBOutlet var watchedBtn: UIButton!
    
    // MARK: - Actions
    
    @IBAction func watchBtnPressed(_ sender: UIButton) {
        if sender.isSelected {
            sender.setTitle("Watched", for: .normal)
        } else {
            sender.setTitle("Unwatched", for: .normal)
        }
    }
    
    // MARK: - Functions
    
    func updateViews(){
        print("Running updateViews() from MyMoviesTableViewCell")
        guard let movie = movie else {return}
        
        movieLbl.text = movie.title
        
        if movie.hasWatched == true {
            watchedBtn.setTitle("Watched", for: .normal)
        } else {
            watchedBtn.setTitle("Unwatched", for: .normal)
        }
    }
}
