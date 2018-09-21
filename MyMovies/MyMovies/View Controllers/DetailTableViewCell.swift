//
//  DetailTableViewCell.swift
//  MyMovies
//
//  Created by Farhan on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBAction func toggleWatched(_ sender: Any) {
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var movie: Movie?{
        didSet{
            updateViews()
        }
    }
    
    func updateViews(){
        guard let title = movie?.title else {return}
        titleLabel.text = title
    }
}
