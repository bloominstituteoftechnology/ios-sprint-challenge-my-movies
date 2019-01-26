

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    //var movieDataController: MovieDataController?
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    @IBOutlet weak var hasWatchedOutlet: UIButton!
    
    var shouldChange: Bool = false
    
    @IBAction func hasWatchedAction(_ sender: Any) {
        
//        if shouldChange == false {
//            hasWatchedOutlet.setTitle("Unwatched", for: .normal)
//            MovieDataController.shared.updateMovie(movie: movie!, hasWatched: false)
//        } else {
//            hasWatchedOutlet.setTitle("Watched", for: .normal)
//            MovieDataController.shared.updateMovie(movie: movie!, hasWatched: true)
//        }
//        shouldChange = !shouldChange
        
        guard let movie = movie else { return }
        
        //movie?.hasWatched == true
        
        if movie.hasWatched == false {
            hasWatchedOutlet.setTitle("Unwatched", for: .normal)
            //movie.hasWatched = false
            MovieDataController.shared.updateMovie(movie: movie, hasWatched: false)
            movie.hasWatched = true
            MovieDataController.shared.updateMovie(movie: movie, hasWatched: true)
        } else {
            hasWatchedOutlet.setTitle("Watched", for: .normal)
            //movie.hasWatched = true
            MovieDataController.shared.updateMovie(movie: movie, hasWatched: true)
            movie.hasWatched = false
            MovieDataController.shared.updateMovie(movie: movie, hasWatched: false)
        }
        
        
        
        //toggleHasWatched = !toggleHasWatched
        
        //movieDataController?.updateMovie(movie: movie, hasWatched: true)
        
    }
    
    static let reuseIdentifier = "MyMovieCell"
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        movieTitleLabel.text = movie?.title
                
        if movie?.hasWatched == false {
            hasWatchedOutlet.setTitle("Unwatched", for: .normal)
        } else {
            hasWatchedOutlet.setTitle("Watched", for: .normal)
        }
    }
    
    
}
