//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Bradley Diroff on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol ChangeSeenDelegate {
func movieSeenChange(_ item: Movie)
}

class MyMoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var myButton: UIButton!
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    var delegate: ChangeSeenDelegate?
    
    @IBAction func toggleSeen(_ sender: Any) {
        guard let movie = movie else {return}
        delegate?.movieSeenChange(movie)
    }

    func updateViews() {
        guard let movie = movie else {return}
        
        myLabel.text = movie.title
        if movie.hasWatched == true {
            myButton.setTitle("Seen",for: .normal)
        } else {
            myButton.setTitle("Unseen",for: .normal)
        }
        
    }
    
}
