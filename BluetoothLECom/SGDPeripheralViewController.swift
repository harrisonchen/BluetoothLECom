//
//  SGDPeripheralViewController.swift
//  BluetoothLECom
//
//  Created by Harrison Chen on 2/6/15.
//  Copyright (c) 2015 StudentGlue. All rights reserved.
//

import UIKit
import CoreBluetooth

class SGDPeripheralViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var textView: UITextView!
    var blePeripheral: BLEPeripheral!
    
    @IBAction func sendData(sender: AnyObject) {
        var dataToSend = textView.text.dataUsingEncoding(NSUTF8StringEncoding)
        
        blePeripheral.sendDataToPeripheral(dataToSend!)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        blePeripheral = BLEPeripheral()
        textView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        blePeripheral.startAdvertisingToPeripheral()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
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
