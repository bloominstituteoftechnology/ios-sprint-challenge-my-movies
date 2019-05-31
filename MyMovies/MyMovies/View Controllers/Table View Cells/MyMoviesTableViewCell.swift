//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Michael Flowers on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MyMoviesTableViewCellDelegate: AnyObject {
    func changeButtonTitle(for cell: UITableViewCell)
}

class MyMoviesTableViewCell: UITableViewCell {

    //MARK: Properties
    var movie: Movie?
    var mc: MovieController?
    weak var delegate: MyMoviesTableViewCellDelegate?
    
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var watchedButtonProperties: UIButton!
    

    @IBAction func changeWatchedButton(_ sender: UIButton) {
         delegate?.changeButtonTitle(for: self)
    }
}
