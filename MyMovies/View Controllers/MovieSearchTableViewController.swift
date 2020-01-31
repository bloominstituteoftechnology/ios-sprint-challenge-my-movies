//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        movieController.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
    
        cell.textLabel?.text = movieController.searchedMovies[indexPath.row].title
        
        let saveButton = movieController.searchedMovies[indexPath.row]
        return cell
    }
    func saveButtonTapped(on cell: )
    
//        movieController.searchForMovie(title: title, completion: { error in
//            if let error = error {
//                print( "Error saving movie from server: \(error.localizedDescription)")
//            }
//            let moc = coreDataStack.shared.mainContext
//            moc.delete(task)
//            do {
//                try moc.save()
//
//            } catch {
//                moc.reset()
//                print("Error saving managed object context: \(error.localizedDescription)")
//            }
//        }
//    }
//
   
    
    var movieController = MovieController()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
//    @IBAction func saveMovie(_ sender: UIButton) {
//        guard let indexPath = tableView.indexPath(for: cell) else { return }
//        let saveMovie = movieController.searchedMovies[indexPath.row]
//        movieController.self
//        tableView.reloadRows(at: [indexPath], with: .automatic)
//    }
    
    
}
