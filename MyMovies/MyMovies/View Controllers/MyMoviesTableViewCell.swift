import UIKit
import CoreData

class MyMoviesTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var movie: Movie? {
        didSet {
            updateViews(movie: movie!)
        }
    }
    
    func updateViews(movie: Movie) {
        
        myMovieTitleLabel.text = movie.title
        
        if movie.hasWatched == false {
            watchedButton.setTitle("Unwatched", for: .normal)
        }else if movie.hasWatched == true {
            watchedButton.setTitle("Watched", for: .normal)

        }
        
        
    }

    @IBOutlet weak var myMovieTitleLabel: UILabel!
    
    @IBOutlet weak var watchedButton: UIButton!
    
    
    @IBAction func didWatchMovie(_ sender: UIButton) {
        print(movie?.hasWatched)
        if movie?.hasWatched == true {
            movie?.hasWatched = false
            watchedButton.setTitle("Unwatched", for: .normal)
        }else if movie?.hasWatched == false {
            movie?.hasWatched = true
            watchedButton.setTitle("Watched", for: .normal)
        }
    }
    
}
