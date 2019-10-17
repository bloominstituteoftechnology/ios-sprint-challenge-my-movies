//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Dillon P on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watchedStatusButton: UIButton!
    
    var movie: Movie?
    var watchedStatusDelegate: ToggleWatchedStatusDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func toggleWatchedStatus(_ sender: Any) {
        guard let movie = movie else { return }
        watchedStatusDelegate?.toggleWatchedStatus(movie: movie)
    }
    

}
