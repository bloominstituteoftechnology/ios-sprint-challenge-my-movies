//
//  UIButtonExtenstion.swift
//  MyMovies
//
//  Created by Jonathan Ferrer on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {

    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.2
        shake.autoreverses = true
        let fromPoint = CGPoint(x: center.x, y: center.y + 10)
        let toPoint = CGPoint(x: center.x, y: center.y - 10)
        let fromValue = NSValue(cgPoint: fromPoint)
        let toValue = NSValue(cgPoint: toPoint)

        shake.fromValue = fromValue
        shake.toValue = toValue

        layer.add(shake, forKey: nil)



    }


}
