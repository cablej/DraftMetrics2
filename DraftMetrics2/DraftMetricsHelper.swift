//
//  DraftMetricsHelper.swift
//  DraftMetrics2
//
//  Created by Jack Cable on 6/2/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit

class DraftMetricsHelper: NSObject {
    class func initializeViewController(viewController: UIViewController) {
        viewController.navigationController?.navigationBar.translucent = false
        viewController.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Monda-Bold", size: 16)!]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Monda-Bold", size: 16)!], forState: .Normal)

    }
}
