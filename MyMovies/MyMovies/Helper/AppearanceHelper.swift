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
        UINavigationBar.appearance().barTintColor = .green
        
        // Styling Naviagatiion Title
        let typerighterFont = UIFont(name: "Courier", size: 20)!

        // Styling Text Fields
        UITextField.appearance().backgroundColor = .white
        
        // Styling Labels
        UILabel.appearance().font = typerighterFont
        UILabel.appearance().backgroundColor = #colorLiteral(red: 0.702133566, green: 0.1309964703, blue: 0.04411000564, alpha: 1)
        UILabel.appearance().tintColor = #colorLiteral(red: 0.1593988137, green: 0.1139150703, blue: 0.4315315673, alpha: 1)
        
        
        // Styling TableViewCell
        UITableViewCell.appearance().backgroundColor = .white
        UITableViewHeaderFooterView.appearance().tintColor = .orange
        UITableViewHeaderFooterView.appearance()
        
        // Styling TableView
        UITableView.appearance().backgroundColor = .white
        
        // Styling Buttons
        UIButton.appearance().backgroundColor = .white
    }
}
