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
    }
    
    @IBAction func addMovieButtonClicked(_ sender: Any) {
        
        // TODO: Implement add movie to CoreData and Firebase
        guard let titleLabelText = titleLabel.text else { return }
        myMoviesController?.createMovie(title: titleLabelText)
        print("button clicked")
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    var myMoviesController: MyMoviesController?
    
}
