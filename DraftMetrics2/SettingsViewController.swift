//
//  SettingsViewController.swift
//  DraftMetrics2
//
//  Created by Jack Cable on 6/2/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit
import Crashlytics
import Branch


class SettingsViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var numberOfTeamsTextField: UITextField!
    @IBOutlet var myPickTextField: UITextField!
    @IBOutlet var roundsPreviewedTextField: UITextField!
    
    @IBOutlet var bestAvailableSlider: UISwitch!
    
    @IBOutlet var saveBarButton: UIBarButtonItem!
    @IBOutlet var reviewBarButton: UIBarButtonItem!
    @IBOutlet var shareBarButton: UIBarButtonItem!
    
    var branchUniversalObject: BranchUniversalObject!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberOfTeamsTextField.delegate = self
        myPickTextField.delegate = self
        roundsPreviewedTextField.delegate = self
        
        DraftMetricsHelper.initializeViewController(self)
        
        saveBarButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Monda-Bold", size: 16)!], forState: .Normal)
        reviewBarButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Monda-Bold", size: 16)!], forState: .Normal)
        shareBarButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Monda-Bold", size: 16)!], forState: .Normal)
        
        Answers.logCustomEventWithName("SettingsPageViewed", customAttributes: [:])
        addDoneButton()
        
        // Initialize a Branch Universal Object for the page the user is viewing
        branchUniversalObject = BranchUniversalObject()
        
        // Define the content that the object represents
        branchUniversalObject.title = "DraftMetrics"
        branchUniversalObject.contentDescription = "DraftMetrics is the ultimate Fantasy Football draft tool."
        branchUniversalObject.imageUrl  = "http://i.imgur.com/iNxFi1y.png"
        // Trigger a view on the content for analytics tracking
        branchUniversalObject.registerView()
        
        // List on Apple Spotlight
        branchUniversalObject.listOnSpotlight()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        numberOfTeamsTextField.text = "\(defaults.objectForKey("NUM_TEAMS")!)"
        myPickTextField.text = "\(defaults.objectForKey("MY_PICK")!)"
        roundsPreviewedTextField.text = "\(defaults.objectForKey("NUM_ROUNDS_IN_ADVANCE")!)"
        bestAvailableSlider.on = defaults.boolForKey("SHOW_BEST_AVAIL")

    }
    
    @IBAction func onSaveButtonTapped(sender: AnyObject) {
        updateDefaults()
        
        numberOfTeamsTextField.resignFirstResponder()
        myPickTextField.resignFirstResponder()
        roundsPreviewedTextField.resignFirstResponder()
    }
    
    func updateDefaults() {
        
        if let numTeams = Int(numberOfTeamsTextField.text!) {
            if numTeams >= 2 && numTeams <= 30 {
                defaults.setInteger(numTeams, forKey: "NUM_TEAMS")
            }
        }
        
        if let myPick = Int(myPickTextField.text!) {
            if myPick >= 1 && myPick <= defaults.integerForKey("NUM_TEAMS") {
                defaults.setInteger(myPick, forKey: "MY_PICK")
            }
        }
        
        if let roundsPreviewed = Int(roundsPreviewedTextField.text!) {
            if roundsPreviewed >= 1 && roundsPreviewed <= 20 {
                defaults.setInteger(roundsPreviewed, forKey: "NUM_ROUNDS_IN_ADVANCE")
            }
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
        doneBarButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Monda-Bold", size: 16)!], forState: .Normal)
        doneBarButton.tintColor = UIColor(red: 216/255, green: 0, blue: 21/255, alpha: 1)
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        numberOfTeamsTextField.inputAccessoryView = keyboardToolbar
        myPickTextField.inputAccessoryView = keyboardToolbar
        roundsPreviewedTextField.inputAccessoryView = keyboardToolbar
    }
    
    @IBAction func updateProjectionsTapped(sender: AnyObject) {
        Fantasy.sharedInstance().saveFilesToDocuments()
        Fantasy.sharedInstance().prepValues()
    }
    
    @IBAction func onReviewButtonTapped(sender: AnyObject) {
        DraftMetricsHelper.presentAlert(self)
        Answers.logCustomEventWithName("ReviewButtonTapped", customAttributes: [:])
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onShareButtonTapped(sender: AnyObject) {
        let linkProperties = BranchLinkProperties()
        linkProperties.feature = "sharing"
        
        // Show the share sheet for the content you want the user to share. A link will be automatically created and put in the message.
        branchUniversalObject.showShareSheetWithLinkProperties(linkProperties,
           andShareText: "I'm drafting my dream team with DraftMetrics. Check it out!",
           fromViewController: self,
           completion: { (activityType, completed) in
            if (completed) {
                // This code path is executed if a successful share occurs
            }
        })
    }
}
