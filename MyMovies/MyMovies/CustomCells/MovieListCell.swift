//
//  MovieListCell.swift
//  MyMovies
//
//  Created by Carolyn Lea on 8/25/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieListCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    weak var delegate: MovieCellDelegate?
    var movie: MovieRepresentation?
    {
        didSet
        {
            updateViews()
        }
    }
    
    
    @IBAction func toggleAddMovieButton(_ sender: Any)
    {
        delegate?.toggleAddedMovie(cell: self)
    }
    
    func updateViews()
    {
        guard let movie = movie else {return}
        titleLabel.text = movie.title
        
        
    }
}
