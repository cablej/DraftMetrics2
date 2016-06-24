//
//  CustomRosterViewController.swift
//  DraftMetrics2
//
//  Created by Jack Cable on 6/21/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit

class CustomRosterViewController: UITableViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet var positionsOutletCollection: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DraftMetricsHelper.initializeViewController(self)
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        var scoring: [AnyObject] = (defaults.objectForKey("ROSTER") as! [AnyObject])
        
        for var i in 0..<scoring.count {
            positionsOutletCollection[i].text = "\(scoring[i])"
        }
        
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        
        let scoring = NSMutableArray()
        
        for var i in 0..<positionsOutletCollection.count {
            if let value = Int(positionsOutletCollection[i].text!) {
                scoring.addObject(value)
            } else {
                scoring.addObject(0)
            }
        }
        
        defaults.setObject(scoring, forKey: "ROSTER")
        
        Fantasy.sharedInstance().prepValues()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
