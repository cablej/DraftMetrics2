//
//  SecondViewController.swift
//  DraftMetrics2
//
//  Created by Jack Cable on 6/1/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit
import HMSegmentedControl
import Crashlytics

class MyPickViewController: UIViewController, UITableViewDataSource {
    
    var positionTitles: NSArray = []
    var positionsControl : HMSegmentedControl?
    var roundControl /* to Major Tom */ : HMSegmentedControl?

    @IBOutlet var tableView: UITableView!
    
    var fantasy = Fantasy.sharedInstance()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var NUM_ROUNDS_IN_ADVANCE: Int = 6;
    
    var recommendedPlayers : NSArray?
    var currentPosition = 0;
    var currentRound = 1;
    var roundToDisplay = 0;
    
    @IBOutlet var recommendedPositionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DraftMetricsHelper.initializeViewController(self)
        
        positionTitles = fantasy.getPositionsArray()
        
        NUM_ROUNDS_IN_ADVANCE = Int((defaults.objectForKey("NUM_ROUNDS_IN_ADVANCE")?.intValue)!)
        
        let titles = NSMutableArray()
        for i in currentRound..<(currentRound + NUM_ROUNDS_IN_ADVANCE) {
            titles.addObject("ROUND \(i)")
        }
        
        roundControl = HMSegmentedControl(sectionTitles: titles as [AnyObject])
        positionsControl = HMSegmentedControl(sectionTitles: positionTitles as [AnyObject])
        
        guard let roundControl = roundControl, let positionsControl = positionsControl else {
            return
        }
        
        roundControl.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 60)
        roundControl.backgroundColor = UIColor(red: 77/255, green: 80/255, blue: 48/255, alpha: 1)
        roundControl.selectionStyle = HMSegmentedControlSelectionStyleBox
        roundControl.selectionIndicatorColor = UIColor(red: 185/255, green: 171/255, blue: 74/255, alpha: 1)
        roundControl.selectionIndicatorBoxOpacity = 1
        roundControl.titleFormatter = {(segmentedControl, title, index, selected) -> NSAttributedString in
            let attString = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.init(name: "Monda-Bold", size: 16)!])
            return attString
        }
        
        roundControl.addTarget(self, action: #selector(self.roundControlChangedValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(roundControl)
        
        positionsControl.frame = CGRectMake(0, 130, UIScreen.mainScreen().bounds.width, 60)
        positionsControl.backgroundColor = UIColor(red: 77/255, green: 80/255, blue: 48/255, alpha: 1)
        positionsControl.selectionStyle = HMSegmentedControlSelectionStyleBox
        positionsControl.selectionIndicatorColor = UIColor(red: 185/255, green: 171/255, blue: 74/255, alpha: 1)
        positionsControl.selectionIndicatorBoxOpacity = 1
        positionsControl.titleFormatter = {(segmentedControl, title, index, selected) -> NSAttributedString in
            let attString = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.init(name: "Monda-Bold", size: 16)!])
            return attString
        }
        positionsControl.addTarget(self, action: #selector(self.positionControlChangedValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        self.view.addSubview(positionsControl)
        
        tableView.dataSource = self
        
    }
    
    func positionControlChangedValue(segmentedControl: HMSegmentedControl) {
        currentPosition = segmentedControl.selectedSegmentIndex
        self.tableView.reloadData()
    }
    
    func roundControlChangedValue(segmentedControl: HMSegmentedControl) {
        roundToDisplay = segmentedControl.selectedSegmentIndex + currentRound
        refreshData(false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NUM_ROUNDS_IN_ADVANCE = Int((defaults.objectForKey("NUM_ROUNDS_IN_ADVANCE")?.intValue)!)
        restartController()
        Answers.logCustomEventWithName("MyPickPageViewed", customAttributes: ["currentPick":Int(fantasy.getCurrentPick())])
        
        DraftMetricsHelper.checkReviewAlert(self)
    }
    
    func restartController() {
        currentRound = Int(fantasy.getNextRoundToDraft())
        roundToDisplay = currentRound
        roundControl?.setSelectedSegmentIndex(0, animated: true)
        
        refreshRoundControl()
        refreshData(true)
    }
    
    func refreshData(recalculate: Bool) {
        if(recalculate) {
            fantasy.setNoCalc(false)
            fantasy.makeCalculations()
            fantasy.calculateData()
        }
        
        recommendedPlayers = fantasy.getPlayersByPositionForRound(Int32(roundToDisplay))
        currentPosition = Int(fantasy.getRecommendedPositionForRound(Int32(roundToDisplay)))
        
        positionsControl?.setSelectedSegmentIndex(UInt(currentPosition), animated: true)
        
        recommendedPositionLabel.text = "RECOMMENDED POSITION: \(positionTitles[currentPosition])"
        refreshDisplay()
    }
    
    func refreshDisplay() {
        
        self.tableView.reloadData()
    }
    
    func refreshRoundControl() {
        let titles = NSMutableArray()
        for i in currentRound..<(currentRound + NUM_ROUNDS_IN_ADVANCE) {
            titles.addObject("ROUND \(i)")
        }
        roundControl?.sectionTitles = titles as [AnyObject]
        roundControl?.reloadInputViews()
        
        positionTitles = fantasy.getPositionsArray()
        positionsControl?.sectionTitles = positionTitles as [AnyObject]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recommendedPlayers = recommendedPlayers else {
            return 0
        }
        if(recommendedPlayers.count == 0) { return 0 }
        return recommendedPlayers[currentPosition].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let recommendedPlayers = recommendedPlayers else {
            return tableView.dequeueReusableCellWithIdentifier("PlayerCell")!
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("PlayerCell") as! PlayerCell
        
        let player = (recommendedPlayers[currentPosition] as! NSArray)[indexPath.row] as! Player
        
        cell.selectButton!.tag = indexPath.row
        
        cell.nameLabel.text = player.name
        var chanceOfAvailability = round(100.0*fantasy.getChanceOfAvailability(player, Int32(roundToDisplay)));
        var chanceOfBest = round(100.0*fantasy.getChanceOfBestAvailable(player, Int32(roundToDisplay)));
        
        if(!chanceOfAvailability.isFinite) {
            chanceOfAvailability = 100;
        }
        
        if(!chanceOfBest.isFinite) {
            chanceOfBest = 100;
        }
        
        if UI_USER_INTERFACE_IDIOM() == .Phone {
            if(!((defaults.objectForKey("SHOW_BEST_AVAIL")?.boolValue)!)) {
                cell.teamLabel.text = NSString(format: "%.0f pts, %.0f%% avl.", player.points, chanceOfAvailability) as String
            } else {
                cell.teamLabel.text = NSString(format: "%.0f pts, %.0f%%, %.0f%%.", player.points, chanceOfAvailability, chanceOfBest) as String
            }
        } else {
            cell.teamLabel.text = NSString(format: "%.0f pts, %.0f%% chance of availability, %.0f%% chance of best available", player.points, chanceOfAvailability, chanceOfBest) as String
        }
        
        return cell
    }
    
    @IBAction func onSelectButtonTapped(sender: UIButton) {
        let row = sender.tag
        
        let player = (recommendedPlayers![(positionsControl?.selectedSegmentIndex)!] as! NSArray)[row]
        
        fantasy.draftPlayer(player as! Player)
        restartController()
        
        DraftMetricsHelper.checkReviewAlert(self)
    }

    
}

