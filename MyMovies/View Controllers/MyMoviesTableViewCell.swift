//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_268 on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var hasWatchedButton: UIButton!
    

    // MARK: - Actions
    
    @IBAction func hasWatchedButtonTapped(_ sender: UIButton) {
        
        guard let movie = movie else { return }
        
        MovieController.shared.toggle(movie: movie)
        
    }
    
    // MARK: - Methods
    
    func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        let hasWatchedButtonTitle = movie.hasWatched ? "Watched" : "Not Watched"
        hasWatchedButton.setTitle(hasWatchedButtonTitle, for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
