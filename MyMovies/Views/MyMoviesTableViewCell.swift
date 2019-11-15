//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Jon Bash on 2019-11-15.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func watchedButtonTapped(_ sender: UIButton) {
        guard let movie = movie else {
            print("can't update watched for cell; no `movie`!")
            return
        }
        movie.hasWatched.toggle()
        updateButtonText()
        MovieController.shared.update(movie: movie)
    }
    
    func updateViews() {
        guard let movie = movie else {
            print("No movie for MyMoviesCell!")
            return
        }
        
        titleLabel.text = movie.title
        updateButtonText()
    }
    
    func updateButtonText() {
        let watchedText = movie!.hasWatched ? "Watched" : "Unwatched"
        watchedButton.setTitle(watchedText, for: .normal)
    }
}
