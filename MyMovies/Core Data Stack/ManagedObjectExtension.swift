//
//  ManagedObjectExtension.swift
//  MyMovies
//
//  Created by brian vilchez on 10/18/19.
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
                NSLog("error saving to persistence store: \(error.localizedDescription)")
                reset()
            }
        }
    }
}
