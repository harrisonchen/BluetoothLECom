//
//  BLEPeripheral.swift
//  BluetoothLECom
//
//  Created by Harrison Chen on 2/12/15.
//  Copyright (c) 2015 StudentGlue. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEPeripheral: NSObject, CBPeripheralManagerDelegate {
    
    var peripheralManager: CBPeripheralManager!
    var transferCharacteristic: CBMutableCharacteristic!
    var dataToSend: NSData!
    var sendDataIndex: Int!
    var sendingEOM: Bool = false
    let MAX_TRANSFER_DATA_LENGTH:Int = 20
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    class var sharedInstance: BLEPeripheral {
        struct Static {
            static let instance: BLEPeripheral = BLEPeripheral()
        }
        return Static.instance
    }
    
    func sendDataToPeripheral(data: NSData) {
        dataToSend = data
        sendDataIndex = 0
        transferData()
    }
    
    func startAdvertisingToPeripheral() {
        if !peripheralManager.isAdvertising {
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: TRANSFER_SERVICE_UUID)]])
        }
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        
        if peripheral.state != CBPeripheralManagerState.PoweredOn {
            return
        }
        
        println("self.peripheralManager powered on.")
        
        transferCharacteristic = CBMutableCharacteristic(type: CBUUID(string: TRANSFER_CHARACTERISTIC_UUID), properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
        
        var transferService = CBMutableService(type: CBUUID(string: TRANSFER_SERVICE_UUID), primary: true)
        
        transferService.characteristics = [transferCharacteristic]
        
        peripheralManager.addService(transferService)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
        
        println("Central subscribed to characteristic: \(characteristic)")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic!) {
        
        println("Central unsubscribed from characteristic")
    }
    
    func transferData() {
        if sendingEOM {
            var didSend:Bool = peripheralManager.updateValue("EOM".dataUsingEncoding(NSUTF8StringEncoding), forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
            
            if didSend {
                
                sendingEOM = false
                println("sending EOM")
                peripheralManager.stopAdvertising()
            }
            
            return
        }
        
        if sendDataIndex >= dataToSend.length {
            return
        }
        
        var didSend:Bool = true
        
        while(didSend) {
            var amountToSend:Int = dataToSend.length - sendDataIndex
            
            if amountToSend > MAX_TRANSFER_DATA_LENGTH {
                amountToSend = MAX_TRANSFER_DATA_LENGTH
            }
            
            var chunk = NSData(bytes: dataToSend.bytes + sendDataIndex, length: amountToSend)
            println("chunk: \(NSString(data: chunk, encoding: NSUTF8StringEncoding)!)")
            
            didSend = peripheralManager.updateValue(chunk, forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
            
            if !didSend {
                println("didnotsend")
                return;
            }
            
            var stringFromData = NSString(data: chunk, encoding: NSUTF8StringEncoding)
            println("Sent" + stringFromData!)
            
            sendDataIndex = sendDataIndex + amountToSend
            
            if sendDataIndex >= dataToSend.length {
                sendingEOM = true
                
                var eomSent = peripheralManager.updateValue("EOM".dataUsingEncoding(NSUTF8StringEncoding), forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
                
                if eomSent {
                    sendingEOM = false
                    println("Sending EOM")
                }
                
                return
            }
        }
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager!) {
        println("Ready to transfer")
        transferData()
    }
}