//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Farhan on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    weak var delegate: SearchTableViewCellDelegate?
    
    @IBAction func saveMovie(_ sender: Any) {
        delegate?.didTapAddMovie(self)
    }
    


}
