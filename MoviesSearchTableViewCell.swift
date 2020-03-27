//
//  MoviesSearchTableViewCell.swift
//  MyMovies
//
//  Created by Bhawnish Kumar on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MoviesSearchTableViewCellDelegate {
    func addMovie(for cell: MoviesSearchTableViewCell)
}
class MoviesSearchTableViewCell: UITableViewCell {

    var movie: Movie?
    var delegate: MoviesSearchTableViewCellDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonTapped(_ sender: UIButton) {
         delegate?.addMovie(for: self)
    }
    
}
