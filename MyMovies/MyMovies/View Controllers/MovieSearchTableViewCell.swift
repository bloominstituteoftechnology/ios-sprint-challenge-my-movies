
import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    @IBAction func addMovieButton(_ sender: Any) {
    }
    
    static let reuseIdentifier = "MovieCell"
    
//    var movie: Movie? {
//        didSet {
//            updateViews()
//        }
//    }
//    
//    func updateViews() {
//        
//        guard let movie = movie else { return }
//        
//        //movieTitleLabel.text = movie.title
//        
//    }
    
    
}
