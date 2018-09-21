//
//  Helpers.swift
//  MyMovies
//
//  Created by Jason Modisett on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    
    func shouldRemoveShadow(_ value: Bool) -> Void {
        if value {
            self.setValue(true, forKey: "hidesShadow")
        } else {
            self.setValue(false, forKey: "hidesShadow")
        }
    }
}
