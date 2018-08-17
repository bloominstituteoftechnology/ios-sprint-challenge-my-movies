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
        Movie(title: movieRepresentation.title)
        do{
            try moc.save()
        }catch{
            NSLog("Error saving Movie: \(error)")
            moc.reset()
            return
        }
    }
    
    func updateCell(){
        guard let movieRepresentation = movieRepresentation else {return}
        titleLabel.text = movieRepresentation.title
    }
    
    // MARK: - Properties
    @IBOutlet weak var titleLabel: UILabel!
    var movieRepresentation: MovieRepresentation? {
        didSet{
            updateCell()
        }
    }
}
