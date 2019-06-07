//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Jonathan Ferrer on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    // where we'll call save to coredata and put
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        guard let title = titleLabel.text else { return }
        let movie = Movie(title: title, hasWatched: false)
        myMovieController.putOnServer(movie: movie)
        addButton.isHidden = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var addButton: UIButton!

    var myMovieController = MyMovieController()

}
