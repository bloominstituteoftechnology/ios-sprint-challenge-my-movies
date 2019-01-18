import UIKit
import CoreData

class MovieSearchTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateViews(){
        guard let movie = movie else {return}
        movieTitleLabel.text = movie.title
        
    }
    var movieController: MovieController?
    var myMovieController: MyMoviesController?
    
    var movie: Movie? {
        didSet{
            updateViews()
        }
    }
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    @IBAction func addMovie(_ sender: Any) {
        let moc = CoreDataStack.shared.mainContext
        
        let savedMovie = movie ?? Movie(context: moc)
        savedMovie.title = movieTitleLabel.text
        savedMovie.hasWatched = false
        savedMovie.identifier = UUID()
        
        
        do {
            try moc.save()
            myMovieController?.saveMovieToServer(movie: savedMovie)
    
        } catch {
            print("Failed to save: \(error)")
        }
    }
}
