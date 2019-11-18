//
//  moviesTableViewCell.swift
//  MyMovies
//
//  Created by Thomas Sabino-Benowitz on 11/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class moviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var seenButton: UIButton!
    
     var movieController: MovieController?
    
    var movie: Movie?
    
    func seenButtonSet() {
        seenButton.setTitle("unseen", for: .normal)
    if movie?.hasWatched == true {
              seenButton.setTitle("Seen (toggle)", for: .normal)
          } else if movie?.hasWatched == false {
              seenButton.setTitle("Unseen (toggle)", for: .normal)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        seenButtonSet()
    }
    @IBAction func seenButtonTapped(_ sender: Any) {
        movie?.hasWatched.toggle()
        movieController?.sendTaskToServer(movie: movie!)
        seenButtonSet()
        
      
    }
    
}
