
//
//  MovieController.swift
//  MyMovies
//
//  Created by Shawn Gee on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

typealias MovieRepsByID = [String: MovieRepresentation]
typealias MovieDict = [String: Any]

class MovieController {
    private let firebaseClient = FirebaseClient()
    
    init() {
        fetchMoviesFromServer()
    }
    
    func fetchMoviesFromServer(completion: (() -> Void)? = nil) {
        firebaseClient.fetchMoviesFromServer { result in
            switch result {
            case .failure(let error):
                NSLog("Error fetching movies from server: \(error)")
            case .success(let movieDicts):
                self.syncMovies(with: movieDicts)
            }
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    
    // MARK: - CRUD
    
    func addMovie(with representation: MovieRepresentation) {
        // Could add functionality to avoid duplication
        guard let movie = Movie(representation) else { return }
        try? CoreDataStack.shared.save()
        firebaseClient.sendMovieToServer(movie)
    }
    
    func save(_ movie: Movie) {
        try? CoreDataStack.shared.save()
        firebaseClient.sendMovieToServer(movie)
    }
    
    func delete(_ movie: Movie) {
        firebaseClient.deleteMovieWithID(movie.identifier)
        CoreDataStack.shared.mainContext.delete(movie)
        try? CoreDataStack.shared.save()
    }
    
    
    // MARK: - Syncing
    
    private func syncMovies(with movieDicts: [MovieDict]) {
        let bgContext = CoreDataStack.shared.container.newBackgroundContext()
        bgContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let mainContext = CoreDataStack.shared.mainContext
        
        var insertedObjectIDs: [NSManagedObjectID]?
        
        bgContext.performAndWait {
            let insertRequest = NSBatchInsertRequest(entity: Movie.entity(), objects: movieDicts)
            insertRequest.resultType = NSBatchInsertRequestResultType.objectIDs
            let result = try? bgContext.execute(insertRequest) as? NSBatchInsertResult
            
            if let objectIDs = result?.result as? [NSManagedObjectID] {
                insertedObjectIDs = objectIDs
            }
        }
        
        if let insertedObjectIDs = insertedObjectIDs {
            let save = [NSInsertedObjectsKey: insertedObjectIDs]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: save, into: [mainContext])
        }
    }
}

