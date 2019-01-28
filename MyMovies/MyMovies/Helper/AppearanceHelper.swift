//
//  AppearanceHelper.swift
//  MyMovies
//
//  Created by Ivan Caldwell on 1/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

struct AppearanceHelper {
    static func setStyle(){
        // Styling Text Fields
        UITextField.appearance().backgroundColor = .white
        
        // Styling Labels
        UILabel.appearance().font = UIFont(name: "Courier", size: 20)!
        UILabel.appearance().backgroundColor = #colorLiteral(red: 0.702133566, green: 0.1309964703, blue: 0.04411000564, alpha: 1)
        
        // Styling TableViewCell
        UITableViewCell.appearance().backgroundColor = .white
        
        // Styling TableViewHeader and TableViewFooter
        UITableViewHeaderFooterView.appearance().tintColor = .black
        
        // Styling TableView
        UITableView.appearance().backgroundColor = .white
        
        // Styling Buttons
        UIButton.appearance().backgroundColor = .white
    }
}
