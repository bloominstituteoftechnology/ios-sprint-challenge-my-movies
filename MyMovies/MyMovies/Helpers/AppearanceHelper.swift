//
//  AppearanceHelper.swift
//  MyMovies
//
//  Created by Lisa Sampson on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

enum Appearance {
    
    // MARK: - Properties
    static let eggplant = UIColor(red: 0.3241, green: 0.1054, blue: 0.5747, alpha: 1.0)
    static let offEggplant = UIColor(red: 0.418, green: 0.2329, blue: 0.6333, alpha: 1.0)
    
    // MARK: - Functions
    static func setupAppearance() {
        UITableViewCell.appearance().backgroundColor = offEggplant
    }
}
