//
//  SearchMovieCell.swift
//  MyMovies
//
//  Created by Simon Elhoej Steinmejer on 17/08/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol SearchMovieCellDelegate: class
{
    func addMovie(with movie: MovieRepresentation)
}

class SearchMovieCell: UITableViewCell
{
    @IBOutlet weak var searchedMovieLabel: UILabel!
    weak var delegate: SearchMovieCellDelegate?
    
    var movie: MovieRepresentation?
    
    @IBAction func handleAddMovie(_ sender: Any)
    {
        guard let movie = movie else { return }
        delegate?.addMovie(with: movie)
    }
    

}
