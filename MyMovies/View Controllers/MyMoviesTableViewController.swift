//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateViews()
    }
    
    
    
    
    //MARK: - Variables
    var movieController = MovieController()
    lazy var movies: [Movie] = []

    
    //MARK: - Functions
    func updateViews() {
        movies = movieController.movies
        tableView.reloadData()
        print("Movies: \(movies.count)")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
        //Section 0 = Has Seen and Section 1 = Not Seen
        var hasSeen = 0
        var notSeen = 0
        
        for i in movies {
            if i.hasWatched == true {
                hasSeen += 1
            } else if i.hasWatched == false {
                notSeen += 1
            }
        }
        
        if section == 0 {
            return hasSeen
        } else {
            return notSeen
        }
         */
        return movies.count
    }
    
    /*override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Has Seen"
        } else {
            return "Not Seen"
        }
    }*/

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath)

        guard let myCell = cell as? MyMovieTableViewCell else {
            return cell
        }
        
        myCell.movie = movies[indexPath.row]
        myCell.movieController = movieController
        return myCell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let movie = movies[indexPath.row]
            CoreDataStack.shared.mainContext.delete(movie)
            do {
                try CoreDataStack.shared.mainContext.save()
                print("Delete Saved")
            } catch {
                CoreDataStack.shared.mainContext.reset()
                print("Error saving delete in MyMoviesTableViewController: \(error)")
            }
            movies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
