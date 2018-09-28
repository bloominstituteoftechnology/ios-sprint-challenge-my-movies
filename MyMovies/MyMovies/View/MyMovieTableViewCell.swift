//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Ilgar Ilyasov on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MyMovieTableViewCellDelegate: class {
    func unwatchedButtonTapped(on cell: MyMovieTableViewCell)
}

class MyMovieTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var myMovieCellDelegate: MyMovieTableViewCellDelegate?
    var movieController: MovieController?
    var movie: Movie?
    
    // MARK: - Outlets
    
    @IBOutlet weak var myMovieLabel: UILabel!
    @IBOutlet weak var unwatchedButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func unwatchedButtonTapped(_ sender: Any) {
        myMovieCellDelegate?.unwatchedButtonTapped(on: self)
    }
    
    func updateViews() {
        //
    }
}
