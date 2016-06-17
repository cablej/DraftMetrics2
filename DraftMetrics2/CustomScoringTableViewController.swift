//
//  CustomScoringTableViewController
//  DraftMetrics2
//
//  Created by Jack Cable on 6/14/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit

class CustomScoringTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var passingYardsFirstField: UITextField!
    @IBOutlet var passingYardsSecondField: UITextField!
    @IBOutlet var passingTouchdownField: UITextField!
    @IBOutlet var interceptionField: UITextField!
    @IBOutlet var rushingYardsFirstField: UITextField!
    @IBOutlet var rushingYardsSecondField: UITextField!
    @IBOutlet var rushingTouchdownField: UITextField!
    @IBOutlet var receptionsFirstField: UITextField!
    @IBOutlet var receptionsSecondField: UITextField!
    @IBOutlet var receivingYardsFirstField: UITextField!
    @IBOutlet var receivingYardsSecondField: UITextField!
    @IBOutlet var receivingTouchdownField: UITextField!
    @IBOutlet var passing2PtConversionField: UITextField!
    @IBOutlet var rushing2PtConversionField: UITextField!
    @IBOutlet var fumblesLostField: UITextField!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DraftMetricsHelper.initializeViewController(self)
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        var scoring: [AnyObject] = (defaults.objectForKey("SCORING") as! [AnyObject])
        var passingFirst = 1 / CFloat(Double(scoring[0] as! NSNumber))
        if !passingFirst.isFinite {
            passingFirst = 1;
        }
        self.passingYardsFirstField.text = String(format: "%.1f", passingFirst)
        self.passingYardsSecondField.text = CFloat(Double(scoring[0] as! NSNumber)) == 0 ? "0" : "1"
        self.passingTouchdownField.text = "\(scoring[1])"
        self.interceptionField.text = "\(scoring[2])"
        var rushingFirst = 1 / CFloat(Double(scoring[3] as! NSNumber))
        if !rushingFirst.isFinite {
            rushingFirst = 1;
        }
        self.rushingYardsFirstField.text = String(format: "%.1f", rushingFirst)
        self.rushingYardsSecondField.text = CFloat(Double(scoring[3] as! NSNumber)) == 0 ? "0" : "1"
        self.rushingTouchdownField.text = "\(scoring[4])"
        var receptionsFirst = 1 / CFloat(Double(scoring[5] as! NSNumber))
        if !receptionsFirst.isFinite {
            receptionsFirst = 1;
        }
        self.receptionsFirstField.text = String(format: "%.1f", receptionsFirst)
        self.receptionsSecondField.text = CFloat(Double(scoring[5] as! NSNumber)) == 0 ? "0" : "1"
        var receivingFirst = 1 / CFloat(Double(scoring[6] as! NSNumber))
        if !receivingFirst.isFinite {
            receivingFirst = 1;
        }
        self.receivingYardsFirstField.text = String(format: "%.1f", receivingFirst)
        self.receivingYardsSecondField.text = CFloat(Double(scoring[6] as! NSNumber)) == 0 ? "0" : "1"
        self.receivingTouchdownField.text = "\(scoring[7])"
        self.passing2PtConversionField.text = "\(scoring[8])"
        self.rushing2PtConversionField.text = "\(scoring[9])"
        self.fumblesLostField.text = "\(scoring[10])"

    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        let newVals: [AnyObject] = [NSNumber(float: Float(passingYardsSecondField.text!)! / Float(passingYardsFirstField.text!)!),
                                    passingTouchdownField.text!, interceptionField.text!, NSNumber(float: Float(rushingYardsSecondField.text!)! / Float(rushingYardsFirstField.text!)!), rushingTouchdownField.text!, NSNumber(float: Float(receptionsSecondField.text!)! / Float(receptionsFirstField.text!)!), NSNumber(float: Float(receivingYardsSecondField.text!)! / Float(receivingYardsFirstField.text!)!), receivingTouchdownField.text!, passing2PtConversionField.text!, rushing2PtConversionField.text!, fumblesLostField.text!]
        defaults.setObject(newVals, forKey: "SCORING")
        Fantasy.sharedInstance().prepValues()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
}
