//
//  SearchedMovieTableViewCell.swift
//  MyMovies
//
//  Created by brian vilchez on 10/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchedMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    var movieController = MovieController()
    var movieRep: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
   
    
    private func updateViews() {
        guard let movieRep = movieRep else {return}
        titleLabel.text = movieRep.title
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        guard let title = titleLabel.text else {return}
        movieController.addMovie(withTitle: title, context: CoreDataStack.shared.mainContext)
        print(title)
    }
    
}
