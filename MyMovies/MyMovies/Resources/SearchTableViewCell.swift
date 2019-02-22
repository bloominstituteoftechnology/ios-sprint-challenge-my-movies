//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Julian A. Fordyce on 2/22/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit


protocol SearchTableViewCellDelegate: class {
    func addMovie(cell: SearchTableViewCell)
}

class SearchTableViewCell: UITableViewCell {
    
    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        addButton.setTitle("Add Movie", for: .normal)
    }
    
    @IBAction func add(_ sender: Any) {
        addButton.setTitle("Added", for: .normal)
        delegate?.addMovie(cell: self)
    }
    
    
    
    
    // MARK: - Properties
    var delegate: SearchTableViewCellDelegate?
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
}

