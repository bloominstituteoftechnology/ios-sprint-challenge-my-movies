import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    
    // MARK:- View updater method
    private func updateViews() {
        guard let title = movieTitle else { return }
        
        titleLabel.text = title
        addButton.tintColor = .red
        addButton.setTitle("ADD TO MY MOVIES", for: .normal)
    }
    
    
    // MARK:- IBActions
    @IBAction func addMovie(_ sender: Any) {
        guard let movieController = movieController,
            let title = movieTitle else { return }
        
        movieController.addMovie(with: title)
        addButton.tintColor = .orange
        addButton.setTitle("ADDED!", for: .normal)
    }
    
    
    // MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK:- Properties & types
    var movieController: MovieController?
    var movieTitle: String? { didSet { updateViews() }}
}
