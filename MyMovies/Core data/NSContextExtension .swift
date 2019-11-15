//
//  NSContextExtension .swift
//  MyMovies
//
//  Created by brian vilchez on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    func saveChanges() {
        do {
            try save()
        } catch {
            NSLog("failed to save changes.")
        }
    }
}
