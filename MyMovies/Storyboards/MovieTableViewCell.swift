//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Sammy Alvarado on 8/17/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreData

protocol MovieCellDelegate: class {
    func didUpdateMove(cell: MovieTableViewCell)
}

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var hasWatchedToggle: UIButton!

    static let resuseIdentifier = "MyMovieCell"
    var movieController = MovieController()

    var movie: Movie? {
        didSet {
            updateViews()
        }
    }

    weak var delegate: MovieCellDelegate?

    @IBAction func hasWatchedButton(_ sender: Any) {
        delegate?.didUpdateMove(cell: self)
//        movie?.hasWatched.toggle()
//        updateViews()
//        movieController.fetchMovieFromServer()

//        do {
//            try CoreDataStack.shared.mainContext.save()
//        } catch {
//            NSLog("Error saving managed object context: \(error)")
//        }
    }

    private func updateViews() {
        guard let movie = movie else { return }

        movieTitle.text = movie.title
        hasWatchedToggle.setImage((movie.hasWatched) ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
    }


//       override func awakeFromNib() {
//           super.awakeFromNib()
//           // Initialization code
//       }
//
//       override func setSelected(_ selected: Bool, animated: Bool) {
//           super.setSelected(selected, animated: animated)
//
//        if selected {
//            backgroundColor = .blue
//        } else {
//            backgroundColor = .clear
//        }
//
//           // Configure the view for the selected state
//       }

}



