//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Cody Morley on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBAction func addMovie(_ sender: Any) {
        
    }
    
    private func updateViews() {
        titleLabel.text = movie?.title
    }
    
}
