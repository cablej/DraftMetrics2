//
//  FirstViewController.swift
//  DraftMetrics2
//
//  Created by Jack Cable on 6/1/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit

class MainPageViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    let TAG_OFFSET = 1000;
    
    var fantasy = Fantasy.sharedInstance()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var availablePlayers = []
    var filteredPlayers = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        DraftMetricsHelper.initializeViewController(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshData()
    }

    func refreshData() {
        fantasy.setNoCalc(true)
        fantasy.makeCalculations()
        fantasy.calculateData()
        
        availablePlayers = fantasy.getAvailablePlayers()
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
        print("\(index) clicked.")
    }

}

