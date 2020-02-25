//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Gerardo Hernandez on 2/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchCellDelegate: class {
    func addMovieButtonTapped(sender: MovieTableViewCell)
}
class MovieTableViewCell: UITableViewCell {

    
    // MARK: - Properties
    
    var title: String? {
        didSet{
            movieTitleLable.text = title
        }
    }
    var delegate: MovieSearchCellDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var movieTitleLable: UILabel!
    
    //MARK: - IBActions
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        delegate?.addMovieButtonTapped(sender: self)
    }
    
    

}
