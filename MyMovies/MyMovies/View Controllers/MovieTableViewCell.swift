//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_34 on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MovieTableViewCellDelegate: class {
    func addMovie(for cell: MovieTableViewCell)
}

class MovieTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    weak var delegate: MovieTableViewCellDelegate?
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - Outlets
    @IBOutlet weak var addMovie: UIButton!
    
    @IBAction func addMovie(_ sender: Any) {
        delegate?.addMovie(for: self)
    }
        
    private func updateViews() {
        
        do {
            let moc = CoreDataStack.shared.mainContext
            try moc.save()
        } catch {
            NSLog("Error saving managed object context movie title: \(error)")
        }
    }
}
