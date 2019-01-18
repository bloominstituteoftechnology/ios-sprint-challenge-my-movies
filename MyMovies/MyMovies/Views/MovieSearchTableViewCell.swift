//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Benjamin Hakes on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addMovieButton.setTitleColor(UIColor.darkColor, for: .normal)
    }
    
    @IBAction func addMovieButtonClicked(_ sender: Any) {
        
        guard let titleLabelText = titleLabel.text else { return }
        myMoviesController?.createMovie(title: titleLabelText)
        addMovieButton.backgroundColor = UIColor.darkColor
        addMovieButton.setTitleColor(UIColor.accentColor, for: .normal)
        addMovieButton.setTitle("Movie Added", for: .normal)
        print("button clicked")
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    var myMoviesController: MyMoviesController?
    
}
