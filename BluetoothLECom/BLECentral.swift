//
//  BLECentral.swift
//  BluetoothLECom
//
//  Created by Harrison Chen on 2/12/15.
//  Copyright (c) 2015 StudentGlue. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLECentral: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral!
    var data: NSMutableData!
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        data = NSMutableData()
    }
    
    func startScan() {
        centralManager.scanForPeripheralsWithServices([CBUUID(string: TRANSFER_SERVICE_UUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        
        println("Scanning started")
    }
    
    func stopScan() {
        centralManager.stopScan()
        
        println("Scanning stopped")
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        println("Discovered: \(peripheral)")
        
        if discoveredPeripheral != peripheral {
            discoveredPeripheral = peripheral
            
            println("Connecting to peripheral: \(peripheral)")
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        
        println("Failed to connect to peripheral: \(peripheral), " + error.localizedDescription)
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        
        println("Connected to peripheral: \(peripheral)")
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
            return
        }
        
        println("didDiscoverCharacteristicsForService: \(service)")
        
        for characteristic in service.characteristics {
            if ((characteristic as CBCharacteristic).UUID.isEqual(CBUUID(string: TRANSFER_CHARACTERISTIC_UUID))) {
                println("Discovered characteristic: \(characteristic)")
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
            data.length = 0
            //            peripheral.setNotifyValue(false, forCharacteristic: characteristic)
            //            centralManager.cancelPeripheralConnection(peripheral)
        }
        else {
            data.appendData(characteristic.value)
            println("appendData: \(NSString(data: characteristic.value, encoding: NSUTF8StringEncoding)!)")
            
            println("Received: " + stringFromData!)
        }
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
    }
}