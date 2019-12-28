//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Joe Thunder on 12/28/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

enum WatchStatus: String{
    case watched = "Watched"
    case notWatched = "Not Watched"
}
class MyMoviesTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    let movieController = MovieController()
    
    var movie: Movies? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        
    }
    
    
    @IBAction func hasWatchedButtonPressed(_ sender: Any) {
        guard let title = hasWatchedButton.titleLabel?.text else { return }
        if title == "Watched" {
            self.hasWatchedButton.setTitle(WatchStatus.notWatched.rawValue, for: .normal)
        } else if title == "Not Watched" {
            DispatchQueue.main.async {
                self.hasWatchedButton.setTitle(WatchStatus.watched.rawValue, for: .highlighted)
            }
           
        }
    }
    

}
