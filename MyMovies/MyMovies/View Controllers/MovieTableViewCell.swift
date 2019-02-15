//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_34 on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    var movieRepresentation: MovieRepresentation?
    
    @IBOutlet weak var addMovie: UIButton!
    
    @IBAction func addMovie(_ sender: Any) {
        guard let movieRepresentation = movieRepresentation else { return }
        
        
        
        do {
            let moc = CoreDataStack.shared.mainContext
            try moc.save()
        } catch {
            NSLog("Error saving managed object context movie title: \(error)")
        }
    }
}
