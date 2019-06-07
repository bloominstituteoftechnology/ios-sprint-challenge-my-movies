//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Jonathan Ferrer on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

    @IBAction func isWatchedButtonPressed(_ sender: UIButton){
        guard let movie = movie else { return }

        if movie.hasWatched == false {
            movie.hasWatched = true
            do {
                try CoreDataStack.shared.save()
                myMovieController?.putOnServer(movie: movie)
            } catch {
                NSLog("\(error)")
            }
        } else {
            movie.hasWatched = false
            do {
                try CoreDataStack.shared.save()
                myMovieController?.putOnServer(movie: movie)
            } catch {
                NSLog("\(error)")
            }
        }
    }

    func updateViews() {
        guard let movie = movie else { return }
        if movie.hasWatched == true {
            isWatchedButton.setTitle("Watched", for: .normal)
        } else {
            isWatchedButton.setTitle("Unwatched", for: .normal)
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var isWatchedButton: UIButton!

    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var myMovieController: MyMovieController?

}
