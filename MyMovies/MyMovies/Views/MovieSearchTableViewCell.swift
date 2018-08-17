//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Andrew Dhan on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

private let moc = CoreDataStack.shared.mainContext

class MovieSearchTableViewCell: UITableViewCell {

    @IBAction func addMovie(_ sender: Any) {
        guard let movieRepresentation = movieRepresentation else {return}
        movieController?.createAndSave(movieRepresentation: movieRepresentation)
 //create and save to insert
    }
    
    func updateCell(){
        guard let movieRepresentation = movieRepresentation else {return}
        titleLabel.text = movieRepresentation.title
    }
    
    // MARK: - Properties
    @IBOutlet weak var titleLabel: UILabel!
    var movieController: MovieController?
    var movieRepresentation: MovieRepresentation? {
        didSet{
            updateCell()
        }
    }
}
