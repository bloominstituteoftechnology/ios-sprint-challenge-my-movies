//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Jonalynn Masters on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    var movieController: MovieController?
    var movieRepresentation: MovieRepresentation?

    @IBOutlet weak var addMovieButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        addMovieButton.layer.cornerRadius = 6
        addMovieButton.layer.borderColor = UIColor.gray.cgColor
        addMovieButton.layer.borderWidth = 1.5
        addMovieButton.setTitleColor(.gray, for: .normal)
    }

    @IBAction func addMovieTapped(_ sender: UIButton) {
        guard let movieController = movieController,
            let movieRep = movieRepresentation else { return }

        movieController.addMovie(movieRepresentation: movieRep)
        addMovieButton.setTitleColor(.green, for: .normal)
        addMovieButton.layer.borderColor = UIColor.movieDBGreen.cgColor
    }
}
extension UIColor {
    static let movieDBGreen = UIColor(red: 0.00, green: 0.82, blue: 0.47, alpha: 1.00)
    static let movieDBDarkBlue = UIColor(red: 0.03, green: 0.11, blue: 0.14, alpha: 1.00)
}
