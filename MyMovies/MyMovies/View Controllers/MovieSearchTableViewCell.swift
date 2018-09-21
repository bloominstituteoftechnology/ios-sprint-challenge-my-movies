//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Moin Uddin on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchTableViewCellDelegate: class {
    func addMovie(movie: MovieRepresentation)
}

class MovieSearchTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews() {
        guard let movieRep = movieRep else { return }
        movieTitle.text = movieRep.title
    }
    
    var movieRep: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func addMovie(_ sender: Any) {
        guard let movieRep = movieRep else { return }
        delegate?.addMovie(movie: movieRep)
    }
    
    var delegate: MovieSearchTableViewCellDelegate?
    

    @IBOutlet weak var movieTitle: UILabel!
    
    
    

}
