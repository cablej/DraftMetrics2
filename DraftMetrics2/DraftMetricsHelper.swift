//
//  DraftMetricsHelper.swift
//  DraftMetrics2
//
//  Created by Jack Cable on 6/2/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

class DraftMetricsHelper: NSObject, SKStoreProductViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    let storeViewController = SKStoreProductViewController()
    let mailer = MFMailComposeViewController()
    
    static let sharedInstance = DraftMetricsHelper()
    
    override init() {
        super.init()
    }
    
    class func initializeViewController(viewController: UIViewController) {
        viewController.navigationController?.navigationBar.translucent = false
        viewController.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Monda-Bold", size: 16)!]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Monda-Bold", size: 16)!], forState: .Normal)
        
    }
    
    class func checkReviewAlert(viewController: UIViewController) {
        if(Fantasy.sharedInstance().draftHasFinished()) {
            let alert = UIAlertController(title: "Are you loving DraftMetrics?", message: nil, preferredStyle: .Alert)
        
            alert.addAction(UIAlertAction(title: "Not really.", style: .Default, handler: { (action) in
                let alert = UIAlertController(title: "Want to contact us?", message: "We value your feedback.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "No thanks.", style: .Default, handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) in
                    DraftMetricsHelper.sharedInstance.mailer.mailComposeDelegate = DraftMetricsHelper.sharedInstance
                    DraftMetricsHelper.sharedInstance.mailer.setSubject("DraftMetrics Feedback")
                    
                    DraftMetricsHelper.sharedInstance.mailer.setToRecipients(["jackcableapps@gmail.com"])
                    viewController.presentViewController(DraftMetricsHelper.sharedInstance.mailer, animated: true, completion: nil)
                }))
                viewController.presentViewController(alert, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Yes!", style: .Default, handler: { (action) in
                
                let alert = UIAlertController(title: "Want to review the app?", message: "We value your feedback.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "No thanks.", style: .Default, handler: nil))
                alert.addAction(UIAlertAction(title: "Sure!", style: .Default, handler: { (action) in
                    
                    let productParameters: [String:AnyObject]! = [SKStoreProductParameterITunesItemIdentifier : "907590482"]
                    
                    DraftMetricsHelper.sharedInstance.storeViewController.delegate = DraftMetricsHelper.sharedInstance
                    
                    DraftMetricsHelper.sharedInstance.storeViewController.loadProductWithParameters(productParameters, completionBlock: nil)
                    
                    
                    viewController.presentViewController(DraftMetricsHelper.sharedInstance.storeViewController, animated: true, completion: nil)
                    
                }))
                viewController.presentViewController(alert, animated: true, completion: nil)
            }))
            viewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        storeViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        mailer.dismissViewControllerAnimated(true, completion: nil)
    }

}
