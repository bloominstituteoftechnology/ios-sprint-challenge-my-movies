
import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    var movieDataController: MovieDataController?
    
    var movieController = MovieController()
    
    @IBAction func addMovieButton(_ sender: Any) {
        
        guard let labelText = movieTitleLabel.text else { return }
        
        //let moc = CoreDataStack.shared.mainContext
        
        movieDataController?.createMovie(title: labelText, hasWatched: false)
        
    }
    
    static let reuseIdentifier = "MovieCell"
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        
        guard let movie = movie else { return }
        
        //movieTitleLabel.text = movieController.searchedMovies[indexPath.row].title
        
    }
    
    
}
