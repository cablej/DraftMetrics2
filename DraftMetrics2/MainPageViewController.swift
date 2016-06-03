//
//  FirstViewController.swift
//  DraftMetrics2
//
//  Created by Jack Cable on 6/1/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit

class MainPageViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var tableView: UITableView!
    let TAG_OFFSET = 1000;
    
    var fantasy = Fantasy.sharedInstance()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var availablePlayers = NSMutableArray()
    var filteredPlayers = NSMutableArray()
    
    @IBOutlet var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        searchTextField.delegate = self
        
        DraftMetricsHelper.initializeViewController(self)
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
        
        availablePlayers = NSMutableArray(array: fantasy.getAvailablePlayers())
        filteredPlayers = availablePlayers
        
        if(fantasy.isUserPick()) { self.title = NSString(format: "Round %i, Pick %i", fantasy.getCurrentRound(), fantasy.getCurrentPick()) as String }
        else { self.title = "Your Pick!" }

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
        
        cell.selectButton.tag = TAG_OFFSET + indexPath.row
        
        let player = filteredPlayers[indexPath.row] as! Player
        
        cell.nameLabel.text = player.name
        cell.teamLabel.text = player.team
        
        return cell
    }
    
    @IBAction func onSelectButtonTapped(sender: UIButton) {
        let index = sender.tag - TAG_OFFSET
        let player = filteredPlayers[index]
        fantasy.draftPlayer(player as! Player)
        filteredPlayers.removeObjectAtIndex(index)
        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Fade)
        searchTextField.resignFirstResponder()
    }

    @IBAction func onSearchBarEditingChanged(sender: UITextField) {
        if(sender.text!.isEmpty) {
            filteredPlayers = availablePlayers
        } else {
            filteredPlayers = NSMutableArray(array: availablePlayers.filter({ (player) -> Bool in
                let tmp: NSString = player.name
                let range = tmp.rangeOfString(sender.text!, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return range.location != NSNotFound
            }))
        }
        self.tableView.reloadData()
    }
}

