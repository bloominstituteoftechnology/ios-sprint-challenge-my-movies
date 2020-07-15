//
//  String+Helpers.swift
//  MyMovies
//
//  Created by Nick Nguyen on 7/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

extension String {
  static let json = "json"
  func uuid() -> UUID? {
    return UUID(uuidString: self) ?? nil
  }
}

struct HTTPMethod {
  static let put = "PUT"
  static let get = "GET"
  static let delete = "DELETE"
  static let post = "POST"
}
