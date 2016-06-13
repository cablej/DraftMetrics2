//
//  SettingsViewController.swift
//  DraftMetrics2
//
//  Created by Jack Cable on 6/2/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet var numberOfTeamsTextField: UITextField!
    @IBOutlet var myPickTextField: UITextField!
    @IBOutlet var roundsPreviewedTextField: UITextField!
    
    @IBOutlet var bestAvailableSlider: UISwitch!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DraftMetricsHelper.initializeViewController(self)
        
        addDoneButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        numberOfTeamsTextField.text = "\(defaults.objectForKey("NUM_TEAMS")!)"
        myPickTextField.text = "\(defaults.objectForKey("MY_PICK")!)"
        roundsPreviewedTextField.text = "\(defaults.objectForKey("NUM_ROUNDS_IN_ADVANCE")!)"
        bestAvailableSlider.on = defaults.boolForKey("SHOW_BEST_AVAIL")

    }
    
    @IBAction func onSaveButtonTapped(sender: AnyObject) {
        updateDefaults()
    }
    
    func updateDefaults() {
        
        if let numTeams = Int(numberOfTeamsTextField.text!) {
            defaults.setInteger(numTeams, forKey: "NUM_TEAMS")
        }
        
        if let myPick = Int(myPickTextField.text!) {
            defaults.setInteger(myPick, forKey: "MY_PICK")
        }
        
        if let roundsPreviewed = Int(roundsPreviewedTextField.text!) {
            defaults.setInteger(roundsPreviewed, forKey: "NUM_ROUNDS_IN_ADVANCE")
        }
        
        defaults.setBool(bestAvailableSlider.on, forKey: "SHOW_BEST_AVAIL")
    }
    
    
    @IBAction func onTextFieldEditingEnded(sender: AnyObject) {
        updateDefaults()
    }
    
    @IBAction func onSliderValueChanged(sender: AnyObject) {
        updateDefaults()
    }
    
    func addDoneButton() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
                                            target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .Done,
                                            target: view, action: #selector(UIView.endEditing(_:)))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        numberOfTeamsTextField.inputAccessoryView = keyboardToolbar
        myPickTextField.inputAccessoryView = keyboardToolbar
        roundsPreviewedTextField.inputAccessoryView = keyboardToolbar
    }
    
}
