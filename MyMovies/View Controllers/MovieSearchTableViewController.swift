//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    var searchButton: UIButton!
   

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

    @objc func searchButtonTapped(movie: Movie) {
        
        movieController.myMovies.append(movie)

    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        
        cell.textLabel?.text = movieController.searchedMovies[indexPath.row].title
        
        let searchButton = UIButton(type: .system)
        searchButton.setTitle("Add Movie", for: .normal)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.addTarget(self, action: #selector(searchButtonTapped(movie:)), for: .touchUpInside)
        cell.addSubview(searchButton)
        searchButton.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -20.0).isActive = true
        searchButton.centerYAnchor.constraint(equalTo: cell.centerYAnchor, constant: 0.0).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        searchButton.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
        
        
        return cell
    }
    
    var movieController = MovieController()
    
    @IBOutlet weak var searchBar: UISearchBar!
}
