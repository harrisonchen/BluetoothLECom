//
//  HCLobbyViewController.swift
//  BluetoothLECom
//
//  Created by Harrison Chen on 2/14/15.
//  Copyright (c) 2015 StudentGlue. All rights reserved.
//

import UIKit

class HCLobbyViewController: UIViewController {
    var bleCentral: BLECentral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("HCLobbyViewController loaded")

        bleCentral = BLECentral.sharedInstance
        bleCentral.startScan()
    }
    
    override func viewWillDisappear(animated: Bool) {
        bleCentral?.stopScan()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
