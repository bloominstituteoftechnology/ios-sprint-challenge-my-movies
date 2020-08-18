# MyMovies

### Instructions

**Please read this entire README to make sure you understand what is expected of you before you begin.**

In your solution, it is especially important that you follow best practices such as MVC and good, consistent code style. You will be scored on these aspects as well as the project requirements below.

Begin by forking this repository. Clone your forked repository to your machine. Use the provided Xcode project in the repository as it contains starter code. Commit as appropriate while you work. Push your final project to GitHub, then create a pull request back to this original repository.

**You will have 3 hours to complete this sprint challenge**

Good luck!

## Requirements

This project uses The Movie DB API. The starter project has search functionality working for you already, as that isn't the point of this Sprint Challenge. There is no need to reference the API's documentation whatsoever.

The requirements for this project are as follows:

### Data Modeling

//create files

1. A `Movie` Core Data object. It should be comprised of the following attributes: `identifier` of type `UUID`, `title` of type `String`, and `hasWatched` of type `Bool`. You'll need to create a Core Data model file and set up your entity with the above attributes. Remember to consider things like Core Data optionality and default values for your attributes. You'll also need to create an extension to the Movie type so you can create convenience initializers for use elsewhere in the project.
//step 1 done

2. A `MovieRepresentation` object for sending data to/from Firebase. Its attributes should match the properties found in the `Movie` managed object (remember the `UUID` type isn't supported in JSON).
// step 2 done

3. The `MovieController` has already been set up to fetch data from TheMovieDB. You'll add more functionality to this class to perform syncing with Firebase as well as any other manipulation of your models you might need.
^^ come back to this


### Changes to `MovieSearchTableViewController`

4. Update the `MovieSearchTableViewController`'s `viewWillDisappear` method to turn the movies that were selected by the user into managed objects and stored in Core Data. The search tableview has been set to allow for multiple cell selection, so the user just needs to tap which movies from the results they want to save.

### Changes to `MyMoviesTableViewController`

5. Display the list of saved movies in the `MyMoviesTableViewController`. You must use an `NSFetchedResultsController` to display the movies. Separate the movies into two sections in the table view by whether they have been watched or not.
6. This table view's prototype cell should let the user update whether they have seen the movie or not. You will toggle the button on the right side of the cell between two different SF Symbols: "film" for unwatched, and "film.fill" for watched.

### Firebase Syncing

//

7. Send changes to the user's saved movies to a Firebase Database when creating, saving, and deleting movies. The database will be one you create in your own Firebase account.

//COMPLETE

8. Synchronize the movies in Firebase with the device's local database in Core Data. Be sure to use a background `NSManagedObjectContext` where necessary to ensure Core Data concurrency is respected. Use the Core Data concurrency debug flag in your scheme to check your work (`-com.apple.CoreData.ConcurrencyDebug 1`).

