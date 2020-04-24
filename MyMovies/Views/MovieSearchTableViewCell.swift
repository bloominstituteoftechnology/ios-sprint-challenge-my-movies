//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Bhawnish Kumar on 4/24/20.
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
    
    @IBOutlet weak var addButton: UIButton!
    var title: String? {
        didSet {
            titleLabel.text = title
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
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.addMovie(for: self)
        if addButton.isSelected {
            animateButton()
        }
    }
    
    func animateButton() {
        let animationOn = {
            self.addButton.transform = CGAffineTransform(scaleX: 2.0, y: 1.5)
        }
        let animationOff = {
            self.addButton.transform = .identity
        }
        UIView.animate(withDuration: 0.40, animations: {
            animationOn()
        }) { (_) in
            animationOff()
        }
    }
    
}

