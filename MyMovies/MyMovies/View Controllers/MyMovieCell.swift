//
//  MyMovieCell.swift
//  MyMovies
//
//  Created by Sergey Osipyan on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func hasWatchedButtonAction(_ sender: Any) {
        
    }
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
}
