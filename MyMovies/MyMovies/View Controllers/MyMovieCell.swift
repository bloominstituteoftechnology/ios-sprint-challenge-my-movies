//
//  MyMovieCell.swift
//  MyMovies
//
//  Created by Jerrick Warren on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class MyMovieCell: UITableViewCell {
    
    private func updateViews(){
        
    }

    
    
    @IBAction func toggleHasWatchedButton(_ sender: Any) {
        
    }
    
    var movie: Movie?{
        didSet {
            updateViews()
        }
    }
    
    // outlets
    
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    
}
