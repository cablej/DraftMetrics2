//
//  FirstViewController.swift
//  DraftMetrics2
//
//  Created by Jack Cable on 6/1/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit
import SDWebImage
import Crashlytics

class MainPageViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var fantasy = Fantasy.sharedInstance()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var availablePlayers = NSMutableArray()
    var filteredPlayers = NSMutableArray()
    
    @IBOutlet var searchTextField: UITextField!
    
    var hasLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        searchTextField.delegate = self
        
        DraftMetricsHelper.initializeViewController(self)
        
        if(defaults.objectForKey("hasLoaded") == nil || defaults.boolForKey("hasLoaded") == false) {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("IntroPage")
            self.presentViewController(vc, animated: true, completion: nil)
            
            defaults.setBool(true, forKey: "hasLoaded")
        }
        
        if(defaults.objectForKey("hasPresentedAlert") == nil) {
            help()
            defaults.setBool(true, forKey: "hasPresentedAlert")
        }
    }
    
    func help() {
        let alert = UIAlertView(title: "Welcome", message: "DraftMetrics calculates the best picks live during your draft. During your draft, select the players drafted. The 'My Pick' tab previews your picks and suggests the best players to choose.", delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    @IBAction func helpButtonTapped(sender: AnyObject) {
        help()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshData()
    }

    func refreshData() {
        fantasy.setNoCalc(true)
        fantasy.makeCalculations()
        fantasy.calculateData()
        
        getRound()
        
        availablePlayers = NSMutableArray(array: fantasy.getAvailablePlayers())
        filterPlayers()

        
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPlayers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlayerCell") as! PlayerCell
        
        let player = filteredPlayers[indexPath.row] as! Player
        
        cell.selectButton!.tag = Int(player.ID)
        
        cell.nameLabel.text = player.name
        cell.teamLabel.text = player.team
        
        if (player.image != nil && !player.image.isEmpty) {
            if let url = NSURL(string: player.image) {
                cell.playerImage.sd_setImageWithURL(url)
            } else {
                cell.playerImage = UIImageView()
            }
        } else {
            cell.playerImage = UIImageView()
        }
        
        return cell
    }
    
    @IBAction func onSelectButtonTapped(sender: UIButton) {
        let id = sender.tag
        var player: Player?
        var index: Int?
        
        for available in filteredPlayers as NSArray as! [Player] {
            if Int(available.ID) == id {
                index = filteredPlayers.indexOfObject(available)
            }
        }
        
        for available in availablePlayers as NSArray as! [Player] {
            if Int(available.ID) == id {
                player = available
                availablePlayers.removeObject(available)
            }
        }
        
        fantasy.draftPlayer(player!)
        
        filterPlayers()
        
        searchTextField.resignFirstResponder()
        
        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index!, inSection: 0)], withRowAnimation: .Fade)
        
        getRound()
        
    }

    @IBAction func onSearchBarEditingChanged(sender: UITextField) {
        filterPlayers()
        self.tableView.reloadData()
    }
    
    func getRound() {
        if(!fantasy.isUserPick()) {
            self.title = NSString(format: "ROUND %i, PICK %i", fantasy.getCurrentRound(), fantasy.getRelativePick()) as String
            self.navigationController?.title = NSString(format: "Round %i, Pick %i", fantasy.getCurrentRound(), fantasy.getRelativePick()) as String
        }
        else {
            self.title = "YOUR PICK!"
            self.navigationController?.title = "Your Pick!"
        }
    }
    
    func filterPlayers() {
        if(searchTextField.text!.isEmpty) {
            filteredPlayers = availablePlayers
        } else {
            filteredPlayers = NSMutableArray(array: availablePlayers.filter({ (player) -> Bool in
                let tmp: NSString = player.name
                let range = tmp.rangeOfString(searchTextField.text!, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return range.location != NSNotFound
            }))
        }
    }
}

