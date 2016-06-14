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
        
        var scoring: [AnyObject] = (defaults.objectForKey("SCORING") as! [AnyObject])
        self.passingYardsFirstField.text = String(format: "%.0f", CFloat(scoring[0] as! String)! == 0 ? 25 : 1 / CFloat(scoring[0] as! String)!)
        self.passingYardsSecondField.text = CFloat(scoring[0])! == 0 ? "0" : "1"
        self.passingTouchdownField.text = "\(scoring[1])"
        self.interceptionField.text = "\(scoring[2])"
        self.rushingYardsFirstField.text = String(format: "%.0f", CFloat(scoring[3])! == 0 ? 10 : 1 / CFloat(scoring[3])!)
        self.rushingYardsSecondField.text = CFloat(scoring[3])! == 0 ? "0" : "1"
        self.rushingTouchdownField.text = "\(scoring[4])"
        self.receptionsFirstField.text = String(format: "%.0f", CFloat(scoring[5])! == 0 ? 1 : 1 / CFloat(scoring[5])!)
        self.receptionsSecondField.text = CFloat(scoring[5])! == 0 ? "0" : "1"
        self.receivingYardsFirstField.text = String(format: "%.0f", CFloat(scoring[6])! == 0 ? 10 : 1 / CFloat(scoring[6])!)
        self.receivingYardsSecondField.text = CFloat(scoring[6])! == 0 ? "0" : "1"
        self.receivingTouchdownField.text = "\(scoring[7])"
        self.passing2PtConversionField.text = "\(scoring[8])"
        self.rushing2PtConversionField.text = "\(scoring[9])"
        self.fumblesLostField.text = "\(scoring[10])"

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
}
