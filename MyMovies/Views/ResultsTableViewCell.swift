//
//  ResultsTableViewCell.swift
//  MyMovies
//
//  Created by Karen Rodriguez on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class ResultsTableViewCell: UITableViewCell {
    
    // MARK: - Outlets

    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Properties
    
    var movieController: MovieController?
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func addMoveTapped(_ sender: UIButton) {
        guard let controller = movieController,
        let movie = movie else { return }
        controller.updateSingleRep(representation: movie)
    }
    
    // MARK: - Private
    
    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
    }
}
