//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Bling Morley on 4/25/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MyMoviesTableViewCell: UITableViewCell {
    //MARK: - Properties -
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seenButton: UIButton!
    
    var movie: Movie? {
        didSet{
            updateViews()
        }
    }
    var delegate: MyMoviesTableViewController?
    
    
    //MARK: - Actions -
    @IBAction func toggleSeen(_ sender: Any) {
        guard let movie = movie else { return }
        movie.hasWatched = !movie.hasWatched
        delegate?.movieController.saveMovies()
    }
    
    
    //MARK: - Methods -
    private func updateViews() {
        self.titleLabel.text = movie?.title
        switch movie?.hasWatched {
        case true:
            self.seenButton.setTitle("Seen", for: .normal)
        case false:
            self.seenButton.setTitle("Not Yet Seen", for: .normal)
        default:
            self.seenButton.setTitle("Seen?", for: .normal)
        }
    }
}
