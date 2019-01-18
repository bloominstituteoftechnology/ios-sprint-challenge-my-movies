//
//  Appearance.swift
//  MyMovies
//
//  Created by Benjamin Hakes on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

enum Appearance {
    static func setupNavAppearance() {
        UINavigationBar.appearance().tintColor = .accentColor
        UINavigationBar.appearance().barTintColor = .darkColor
        UINavigationBar.appearance().largeTitleTextAttributes = [ .foregroundColor: UIColor.accentColor]
        UINavigationBar.appearance().prefersLargeTitles = true
        UINavigationBar.appearance().isTranslucent = false
    }
    
    static func setupSegmentedControlAppearance() {
        UISegmentedControl.appearance().tintColor = .accentColor
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkColor], for: .selected)
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.accentColor], for: .normal)
        
    }
    
}

extension UIColor {
    static let darkColor = UIColor(red: 0.125, green: 0.125, blue: 0.16, alpha: 1.0)
    static let accentColor = UIColor(red: 182/255, green: 60/255, blue: 58/255, alpha: 1)
}
