//
//  HCLobbyViewController.swift
//  BluetoothLECom
//
//  Created by Harrison Chen on 2/14/15.
//  Copyright (c) 2015 StudentGlue. All rights reserved.
//

import UIKit
import CoreBluetooth

class HCLobbyViewController: UIViewController, UITableViewDataSource,
                             UITableViewDelegate, BLECentralDelegate {
    
    @IBOutlet var usersTableView: UITableView!
    var bleCentral: BLECentral!
    var listOfPeripherals: [CBPeripheral]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("HCLobbyViewController loaded")

        usersTableView.dataSource = self
        usersTableView.delegate = self
        listOfPeripherals = [CBPeripheral]()
        bleCentral = BLECentral.sharedInstance
        bleCentral.delegate = self
        bleCentral.startScan()
    }
    
    override func viewWillDisappear(animated: Bool) {
        bleCentral?.stopScan()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfPeripherals.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        
//        cell.textLabel?.text = listOfPeripherals[indexPath.row]
        cell.textLabel?.textColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        cell.backgroundColor = UIColor(red: 43/255, green: 155/255, blue: 255/255, alpha: 1)
        
        return cell
    }

    /* BLECentralDelegate */
    
    func didDiscoverPeripheral(peripheral: CBPeripheral!) {
        if listOfPeripherals.count < 10 {
            println("Discovered: \(peripheral)")
            listOfPeripherals.append(peripheral)
            usersTableView.reloadData()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
