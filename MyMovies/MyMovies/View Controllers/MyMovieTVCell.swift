//
//  MyMovieTVCell.swift
//  MyMovies
//
//  Created by Nikita Thomas on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit


class MyMovieTVCell: UITableViewCell {
    
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var saveButtonLabel: UIButton!
    
    @IBAction func saveButton(_ sender: UIButton) {
        guard let movie = movie else { return }
        if movie.hasWatched {
//            movie.setValue(false, forKey: "hasWatched")
//            delegate?.saveToPersistenceStore()
//            print("Saved hasWatched change")
            delegate?.updateMovie(movie: movie, title: movie.title!, hasWatched: false)
            print(movie.hasWatched)
        } else {
//            movie.setValue(true, forKey: "hasWatched")
//            delegate?.saveToPersistenceStore()
//            print("Saved hasWatched change")
            delegate?.updateMovie(movie: movie, title: movie.title!, hasWatched: true)
            print(movie.hasWatched)
        }
    }
    
    weak var delegate: MyMovieCellDelegate?
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let movie = movie else {return}
        movieLabel.text = movie.title
        if movie.hasWatched {
            saveButtonLabel.setTitle("UnWatch", for: .normal)
        } else {
            saveButtonLabel.setTitle("Watch", for: .normal)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
    }
    
}

protocol MyMovieCellDelegate: class {
    func saveToPersistenceStore()
    func updateMovie(movie: Movie, title: String, hasWatched: Bool)
}
