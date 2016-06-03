//
//  DraftHistoryViewController.swift
//  DraftMetrics2
//
//  Created by Jack Cable on 6/2/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit

class DraftHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var draftHistory = NSMutableArray()
    var fantasy = Fantasy.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DraftMetricsHelper.initializeViewController(self)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshData()
    }
    
    func refreshData() {
        fantasy.setNoCalc(true)
        fantasy.makeCalculations()
        fantasy.calculateData()
        
        draftHistory = NSMutableArray(array: fantasy.getDraftHistory())
        
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return draftHistory.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DraftCell") as! PlayerCell
            
        
        let adjRow = draftHistory.count - 1 - indexPath.row;
        
        let player = draftHistory[adjRow] as! Player
        
        cell.nameLabel.text = player.name
        cell.teamLabel.text = "Pick \(adjRow + 1)"
        
        return cell
    }

    
}
