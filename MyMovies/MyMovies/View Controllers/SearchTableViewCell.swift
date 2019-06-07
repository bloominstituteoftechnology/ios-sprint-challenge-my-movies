//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Diante Lewis-Jolley on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func updateViews() {

        guard let movieRep = movieRep else { return }

        nameLabel.text = movieRep.title
    }


    @IBAction func addMovieButtonTapped(_ sender: Any) {

        guard let title = movieRep?.title else { return }

        movieController.addMovie(title: title)
    }

    
    @IBOutlet weak var addMovieButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    var movieController: MovieController?
    var movieRep: MovieRepresentation? {
        didSet{
            updateViews()
        }
    }

}
