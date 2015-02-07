//
//  SGDCentralViewController.swift
//  BluetoothLECom
//
//  Created by Harrison Chen on 2/6/15.
//  Copyright (c) 2015 StudentGlue. All rights reserved.
//

import UIKit
import CoreBluetooth

class SGDCentralViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet var textView: UITextView!
    var centralManager:CBCentralManager!
    var discoveredPeripheral:CBPeripheral!
    var data:NSMutableData!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        data = NSMutableData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        centralManager.stopScan()
        println("Scanning Stopped")
        super.viewWillDisappear(true)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        if central.state != CBCentralManagerState.PoweredOn {
            return
        }
        
        scan()
    }
    
    func scan() {
        centralManager.scanForPeripheralsWithServices([CBUUID(string: TRANSFER_SERVICE_UUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        
        println("Scanning started")
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        println(RSSI)
        
        println("Discovered: " + peripheral.name, RSSI)
        
        if discoveredPeripheral != peripheral {
            discoveredPeripheral = peripheral
            
            println("Connecting to peripheral: " + peripheral.name)
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        
        println("Failed to connect to peripheral: " + peripheral.name + " -> " + error.localizedDescription)
        cleanup()
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        
        println("Peripheral Connect")
        
        centralManager.stopScan()
        println("Stopped Scanning")
        
        data.length = 0
        
        peripheral.delegate = self
        
        peripheral.discoverServices([CBUUID(string: TRANSFER_SERVICE_UUID)])
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if error != nil {
            println("Error discovering services: " + error.localizedDescription)
            return
        }
        
        for service in peripheral.services {
            peripheral.discoverCharacteristics([CBUUID(string: TRANSFER_CHARACTERISTIC_UUID)], forService: service as CBService)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        if error != nil {
            println("Error discovering characteristics: " + error.localizedDescription)
            cleanup()
            return
        }
        for characteristic in service.characteristics {
            if (characteristic as CBCharacteristic).UUID.isEqual(CBUUID(string: TRANSFER_CHARACTERISTIC_UUID)) {
                peripheral .setNotifyValue(true, forCharacteristic: characteristic as CBCharacteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if error != nil {
            println("Error discovering characteristics: " + error.localizedDescription)
            return
        }
        
        var stringFromData = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding)
        
        if (stringFromData! == "EOM") {
            textView.text = NSString(data: data, encoding: NSUTF8StringEncoding)
            peripheral.setNotifyValue(false, forCharacteristic: characteristic)
            centralManager.cancelPeripheralConnection(peripheral)
        }
        
        data.appendData(characteristic.value)
        
        println("Received: " + stringFromData!)
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if error != nil {
            println("Error changing notification state: " + error.localizedDescription)
            return
        }
        
        if !characteristic.UUID.isEqual(CBUUID(string: TRANSFER_CHARACTERISTIC_UUID)) {
            return
        }
        
        if characteristic.isNotifying {
            println("Notification began on: \(characteristic)")
        }
        else {
            println("Notification stopped on: \(characteristic). Disconnecting")
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        
        println("Peripheral Disconnected")
        discoveredPeripheral = nil
        scan()
    }
    
    func cleanup() {
        
        if discoveredPeripheral.state == CBPeripheralState.Connected {
            return
        }
        
        if discoveredPeripheral.services != nil {
            for service in discoveredPeripheral.services {
                if service.characteristic != nil {
                    for characteristic in (service as CBService).characteristics {
                        if (characteristic as CBCharacteristic).UUID.isEqual(CBUUID(string: TRANSFER_CHARACTERISTIC_UUID)) {
                            if (characteristic as CBCharacteristic).isNotifying {
                                discoveredPeripheral.setNotifyValue(false, forCharacteristic: characteristic as CBCharacteristic)
                                return
                            }
                        }
                    }
                }
            }
        }
        
        centralManager.cancelPeripheralConnection(discoveredPeripheral)
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
