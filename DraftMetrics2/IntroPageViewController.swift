//
//  IntroPageViewController.swift
//  DraftMetrics2
//
//  Created by Jack Cable on 6/13/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit

class IntroPageViewController: UIViewController {

    @IBOutlet var startButton: UIButton!
    
    @IBOutlet var footballImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.layer.borderWidth = 3
        startButton.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).CGColor
        
        fadeTo(0)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func fadeTo(alpha: Int) {
        UIView.animateWithDuration(3, animations: {
            self.footballImage.alpha = CGFloat(alpha)
            }) { (success) in
                self.fadeTo(abs(1 - alpha))
        }
    }
    
}
