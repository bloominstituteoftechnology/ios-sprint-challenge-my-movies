//
//  SearchResultTableViewCell.swift
//  MyMovies
//
//  Created by Bronson Mullens on 6/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    // MARK: - Properites
    
    static let reuseIdentifier = "MovieSearchResultCell"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
}
