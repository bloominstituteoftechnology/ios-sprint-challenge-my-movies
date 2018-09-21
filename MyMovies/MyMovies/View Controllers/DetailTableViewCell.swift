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
    
    weak var delegate: DetailViewCellDelegate?
    
    
    @IBAction func toggleWatched(_ sender: Any) {
        delegate?.didPressWatched(self)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var watchButton: UIButton!
    
    var movie: Movie?{
        didSet{
            updateViews()
        }
    }
    
    func updateViews(){
        guard let movie = movie else {return}
        titleLabel.text = movie.title
        
        if (movie.hasWatched){
            watchButton.setTitle("Not Watched", for: UIControlState.normal)
        } else {
            watchButton.setTitle("Watched", for: UIControlState.normal)
        }
        
    }
}
