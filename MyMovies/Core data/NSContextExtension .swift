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
        if hasChanges {
            do {
                try save()
            } catch {
                NSLog("failed to save changes.")
                reset()
            }
        }
    }
    
    func saveContext(context: NSManagedObjectContext) {
        context.performAndWait {
            do {
                try context.save()
                } catch {
                    NSLog("error saving context: \(error.localizedDescription)")
                    context.reset()
                }
        }
    }
}
