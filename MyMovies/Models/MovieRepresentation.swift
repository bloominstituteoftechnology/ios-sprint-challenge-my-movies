//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

struct MovieRepresentation: Equatable, Codable {
  let title: String
  let identifier: String?
  let hasWatched: Bool?
}


struct MovieRepresentations: Codable {
  let results: [MovieRepresentation]
}

extension Movie {
  var movieRepresentation: MovieRepresentation? {
    guard let title = self.title,
          let identifier = self.identifier
    else {
      print("Cannot get movie's representation; `title` and/or `identefier` missing!")
      return nil
    }
    return MovieRepresentation(title: title, identifier: identifier.uuidString, hasWatched: self.hasWatched)
  }
  
  convenience init?(representation: MovieRepresentation, context: NSManagedObjectContext) {
    self.init(context: context)
    
    self.title = representation.title
    self.hasWatched = representation.hasWatched ?? false
    self.identifier = representation.identifier?.uuid() ?? UUID()
  }
}
