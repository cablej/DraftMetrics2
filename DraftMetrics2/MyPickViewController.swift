//
//  SecondViewController.swift
//  DraftMetrics2
//
//  Created by Jack Cable on 6/1/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit
import HMSegmentedControl

class MyPickViewController: UIViewController, UITableViewDataSource {
    
    let positionsControl = HMSegmentedControl(sectionTitles: ["QB", "RB", "WR", "TE"])
    let roundControl /* to Major Tom */ = HMSegmentedControl(sectionTitles: ["ROUND 1", "ROUND 2", "ROUND 3", "ROUND 4"])

    @IBOutlet var tableView: UITableView!
    
    var fantasy = Fantasy.sharedInstance()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var NUM_ROUNDS_IN_ADVANCE: Int;
    
    var recommendedPlayers = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DraftMetricsHelper.initializeViewController(self)
        
        NUM_ROUNDS_IN_ADVANCE = Int((defaults.objectForKey("NUM_ROUNDS_IN_ADVANCE")?.intValue)!)
        
        var titles = NSMutableArray()
        for i in 1...NUM_ROUNDS_IN_ADVANCE {
            titles.addObject("ROUND \(i)")
        }
        
        roundControl.sectionTitles = [String]()
        roundControl.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 60)
        roundControl.backgroundColor = UIColor(red: 77/255, green: 80/255, blue: 48/255, alpha: 1)
        roundControl.selectionStyle = HMSegmentedControlSelectionStyleBox
        roundControl.selectionIndicatorColor = UIColor(red: 185/255, green: 171/255, blue: 74/255, alpha: 1)
        roundControl.selectionIndicatorBoxOpacity = 1
        roundControl.titleFormatter = {(segmentedControl, title, index, selected) -> NSAttributedString in
            let attString = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Monda-Bold", size: 16)!])
            return attString
        }
        self.view.addSubview(roundControl)
        
        positionsControl.frame = CGRectMake(0, 130, UIScreen.mainScreen().bounds.width, 60)
        positionsControl.backgroundColor = UIColor(red: 77/255, green: 80/255, blue: 48/255, alpha: 1)
        positionsControl.selectionStyle = HMSegmentedControlSelectionStyleBox
        positionsControl.selectionIndicatorColor = UIColor(red: 185/255, green: 171/255, blue: 74/255, alpha: 1)
        positionsControl.selectionIndicatorBoxOpacity = 1
        positionsControl.titleFormatter = {(segmentedControl, title, index, selected) -> NSAttributedString in
            let attString = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Monda-Bold", size: 16)!])
            return attString
        }
        self.view.addSubview(positionsControl)
        
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshData()
    }
    
    func refreshData() {
        fantasy.setNoCalc(false)
        fantasy.makeCalculations()
        fantasy.calculateData()
        
        
        
        
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



}

