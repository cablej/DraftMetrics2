//
//  SecondViewController.swift
//  DraftMetrics2
//
//  Created by Jack Cable on 6/1/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit

class MyPickViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DraftMetricsHelper.initializeViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

