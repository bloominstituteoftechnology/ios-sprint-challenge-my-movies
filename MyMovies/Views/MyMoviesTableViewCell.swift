//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Joe Thunder on 12/28/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

//import UIKit
//
//enum WatchStatus: String {
//    case watched = "Watched"
//    case notWatched = "Not Watched"
//
//    static var toggleStatus: [WatchStatus] {
//        return [.watched, .notWatched]
//    }
//}
//class MyMoviesTableViewCell: UITableViewCell {
//
//
//
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var hasWatchedButton: UIButton!
    
//    let movieController = MovieController()
//    
//    var movie: Movies? {
//        didSet {
//            updateViews()
//        }
//    }
//    
//    func updateViews() {
//        guard let movie = movie else { return }
//        DispatchQueue.main.async {
//            self.titleLabel.text = movie.title
////            self.hasWatchedButton.addTarget(self, action: #selector(self.hasWatchedButtonPressed(_:)), for: .touchUpInside)
//            
//        }
//    }
//    
//    @IBAction func hasWatchedButtonPressed(_ sender: UIButton) {
//        updateWatchStatus()
//    }
//    
//    func updateWatchStatus() {
//        DispatchQueue.main.async {
//                    guard (self.hasWatchedButton.titleLabel?.text) != nil else { return }
//                    if self.movie?.hasWatched == true {
//                        self.movie?.hasWatched.toggle()
//                        self.hasWatchedButton.setTitle("Watched", for: .normal)
//                        print(self.hasWatchedButton.titleLabel?.text)
//                        print(self.movie?.hasWatched.hashValue)
//        //                movieController.update(with: self.movie)
//                        
//                    } else if self.movie?.hasWatched == false {
//                        self.movie?.hasWatched.toggle()
//                        self.hasWatchedButton.setTitle("Not Watched", for: .normal)
//                        print(self.hasWatchedButton.titleLabel?.text)
//                        print(self.movie?.hasWatched.hashValue)
//                    }
//                }
//    }
//    
//}
