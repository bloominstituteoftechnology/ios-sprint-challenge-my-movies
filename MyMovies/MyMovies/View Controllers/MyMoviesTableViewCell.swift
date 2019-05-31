//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Christopher Aronson on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var movieModelController: MovieModelController?

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

    func updateViews() {
        guard let title = movie?.title,
        let hasWatched = movie?.hasWatched
        else { return }

        titleLabel.text = title

        if hasWatched {
            watchedButton.setTitle("Watched", for: .normal)
        } else {
            watchedButton.setTitle("Unwatched", for: .normal)
        }
    }

    @IBAction func watchedButtonTapped(_ sender: Any) {

        guard let movie = movie else { return }

        let context = CoreDataStack.shared.mainContext

        context.performAndWait {
            movieModelController?.update(movie: movie, hasWatch: !movie.hasWatched)
            movieModelController?.save(contetex: context)
        }
    }
}
