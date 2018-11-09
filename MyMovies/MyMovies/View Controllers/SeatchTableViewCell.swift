//
//  SeatchTableViewCell.swift
//  MyMovies
//
//  Created by Yvette Zhukovsky on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class SeatchTableViewCell: UITableViewCell {
    
    var movieRepresentation: MovieRepresentation?{
        didSet{
            updateViews()
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateViews(){
        guard let movieRepresentation = movieRepresentation else {return}
        title.text = movieRepresentation.title
        
    }
    
    
    @IBAction func add(_ sender: Any) {
        guard let movie = movieRepresentation else {return}
        movieController?.create(title: movie.title)
    }
    
    var movieController: MovieController?
    
    @IBOutlet weak var title: UILabel!
    
    
}
