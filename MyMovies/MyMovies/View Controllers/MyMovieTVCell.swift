//
//  MyMovieTVCell.swift
//  MyMovies
//
//  Created by Nikita Thomas on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit


class MyMovieTVCell: UITableViewCell {
    
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var saveButtonLabel: UIButton!
    
    @IBAction func saveButton(_ sender: UIButton) {
        
    }
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let movie = movie else {return}
        movieLabel.text = movie.title
        if movie.hasWatched {
            saveButtonLabel.setTitle("UnWatch", for: .normal)
        } else {
            saveButtonLabel.setTitle("Watch", for: .normal)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
    }
    
}
