//
//  MovieTVCell.swift
//  MyMovies
//
//  Created by Nikita Thomas on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieTVCell: UITableViewCell {
    
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var saveButtonLabel: UIButton!
    
    var stub: MovieRepresentation?
    var movieController: MovieController? 
    
    @IBAction func saveButton(_ sender: UIButton) {
        guard let stub = stub else { return}
        let movie = movieController?.stubToMovie(stub: stub)
        movie?.setValue(true, forKey: "hasWatched")
        
        movieController?.saveToPersistenceStore()
        print("saved")
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
