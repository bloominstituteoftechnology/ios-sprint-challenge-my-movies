//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Michael Flowers on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    var movieRepresentation: MovieRepresentation? {
        didSet {
            print("SearchTableViewCell: movieRepresentation was set")
            updateViews()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButtonProperties: UIButton!

    @IBAction func addMovie(_ sender: UIButton) {
        addButtonProperties.tintColor = .green
        //create a movie from the movieRep that was passed in.
        guard let title = movieRepresentation?.title else { print("SearchTableViewCell: Error unwrapping title from movieRep"); return }
        
        //I could use a delegate protocol here
        MyMovieController.shared.createMovie(title: title)
    }
    
    
    private func updateViews(){
        //update the view with the information that was passed in from the movie rep.
        guard let movieRep = movieRepresentation else { print("Error passing in movie rep"); return }
        nameLabel.text = movieRep.title
    }
    
    
}
