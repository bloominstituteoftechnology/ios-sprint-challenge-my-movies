//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Alex Rhodes on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    var movieController: MovieController?
    
    var movie: MovieRepresentation? {
        didSet {
            setViews()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    private func setViews() {
        
        titleLabel.text = movie?.title
        
        addMovieButton.setTitle("ADD MOIVE", for: .normal)
        addMovieButton.setTitleColor(.white, for: .normal)
        addMovieButton.backgroundColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
        addMovieButton.layer.cornerRadius = 8
    }
    
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        guard let title = titleLabel.text else {return}
        movieController?.createMovie(with: title)
        CoreDataStack.shared.save()
        
    }
}
