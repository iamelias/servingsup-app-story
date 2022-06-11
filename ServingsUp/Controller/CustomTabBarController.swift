//
//  CustomTabBarController.swift
//  ServingsUp
//
//  Created by Elias Hall on 4/30/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation
import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var fistTabImage: UIImageView!
    var secondTabImage: UIImageView!
    var prevSelectedTag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabIconConfig()
    }
    
    func tabIconConfig() {
        var imgView = self.tabBar.subviews[0]
        self.fistTabImage = imgView.subviews.first as? UIImageView
        fistTabImage.contentMode = .center
        imgView = self.tabBar.subviews[1]
        self.secondTabImage = imgView.subviews.first as? UIImageView
        self.secondTabImage.contentMode = .center
        self.delegate = self
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard  prevSelectedTag != item.tag else {return}
        //rotating the icon when tab item is selected
        if item.tag == 0 { //first tab icon
            self.fistTabImage.transform = CGAffineTransform(rotationAngle: Double.pi ) //start at 180 deg position
            UIView.animate(withDuration: 0.25, animations: {
                //                self.fistTabImage.transform = CGAffineTransform(rotationAngle: Double.pi ) //half rotate
                self.fistTabImage.transform = .identity //half rotate back
            })
            prevSelectedTag = 0
        } else { //second tab icon
            self.secondTabImage.transform = CGAffineTransform(rotationAngle: Double.pi ) //start at 180 deg position
            UIView.animate(withDuration: 0.25, animations: {
                // self.secondTabImage.transform = CGAffineTransform(rotationAngle: Double.pi ) //half rotate
                self.secondTabImage.transform = .identity //half rotate back
            })
            prevSelectedTag = 1
        }
    }
}

protocol CustomTabBarControllerDelegate {
    var prevSelectedTag: Int {get set}
}
