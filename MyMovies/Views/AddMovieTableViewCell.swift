//
//  AddMovieTableViewCell.swift
//  MyMovies
//
//  Created by Alex Shillingford on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AddMovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addMovieButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func addMovieTapped(_ sender: UIButton) {
        guard let title = self.textLabel?.text else { return }
        MovieController.sharedController.createMovie(title: title, hasWatched: false)
    }
    
}
