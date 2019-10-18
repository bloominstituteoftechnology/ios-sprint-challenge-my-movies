//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Gi Pyo Kim on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var movieController: MovieController?
    var movieRepresentation: MovieRepresentation? {
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

    func updateViews() {
        guard let movie = movieRepresentation else { return }
        
        titleLabel.text = movie.title
    }
    
    @IBAction func saveButtonTabbed(_ sender: UIButton) {
        guard let movieController = movieController, let movie = movieRepresentation else { return }
        
        movieController.createMovie(title: movie.title, context: CoreDataStack.shared.mainContext)
        
    }
}
