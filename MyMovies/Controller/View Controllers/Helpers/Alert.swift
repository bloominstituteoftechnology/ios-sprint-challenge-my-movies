//
//  Alert.swift
//  MyMovies
//
//  Created by Kenny on 2/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class Alert {
    class func show(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
}
