//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var movieTitleSearchBar: UISearchBar!
    
    var movieController = MovieController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        movieController.searchForMovie(with: searchTerm) { (error) in
            guard error == nil else { return }
            DispatchQueue.main.async {
                self.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieSearchCell",
                                                 for: indexPath)
        
        cell.heightAnchor.constraint(equalToConstant: 45)
        cell.textLabel?.text = movieController.searchedMovies[indexPath.row].title
        disableAutoresizing(textLabel: cell.textLabel!)
        cell.textLabel?.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor,
                                                  constant: -50).isActive = true
        cell.textLabel?.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        cell.textLabel?.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor,
                                                 constant: 25).isActive = true

        return cell
    }
    
    func setDelegate() {
        movieTitleSearchBar.delegate = self
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    func disableAutoresizing(textLabel: UILabel) -> UILabel {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }

    @IBAction func addMovieTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? UITableViewCell,
            let title = cell.textLabel?.text,
            !title.isEmpty
        else { return }
        MyMoviesController.shared.addMovie(title: title)
    }
}
