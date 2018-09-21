//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Dillon McElhinney on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var movie: Movie? {
        didSet{
            updateViews()
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    
    // MARK: - UI Methods
    @IBAction func toggleHasWatched(_ sender: Any) {
        
    }
    
    // MARK: Utility Methods
    func updateViews() {
        
    }
    
}
