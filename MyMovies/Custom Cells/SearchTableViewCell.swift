//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Chris Gonzales on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var movieController: MovieController?
    var movie: Movie? {
        didSet{
            updateViews()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet var movieLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var seachBar: UISearchBar!
    
    // MARK: - Actions
    @IBAction func addToggled(_ sender: UIButton){
        guard let title = textLabel?.text else { return }
        if let movie = movie {
            movieController?.update(movie: movie,
                                    hasWatched: movie.hasWatched,
                                    identifier: movie.identifier!,
                                    title: title)
            updateViews()
        } else {
            movieController?.createMovie(title: title)
        }
    }
    
    // MARK:  - View Lifecycle
    
    private func updateViews(){
        guard let movie = movie else { return }
        
        movieLabel.text = movie.title
        addButton.titleLabel?.text = watchedStatus(for: movie)
        
    }
    
    // MARK: - Methods
    
    private func watchedStatus(for movie: Movie) -> String {
        if !movie.hasWatched {
            return "add"
        } else {
            return "remove"
        }
    }
}
