//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Jeremy Taylor on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBAction func addMovie(_ sender: Any) {
        guard let title = titleLabel.text else { return }
        
        let _ = Movie(title: title)
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error Saving to Core Data: \(error)")
        }
        
    }
}
