//
//  SGDPeripheralViewController.swift
//  BluetoothLECom
//
//  Created by Harrison Chen on 2/6/15.
//  Copyright (c) 2015 StudentGlue. All rights reserved.
//

import UIKit
import CoreBluetooth

class SGDPeripheralViewController: UIViewController, CBPeripheralManagerDelegate, UITextViewDelegate {
    

    @IBOutlet var textView: UITextView!
    var peripheralManager:CBPeripheralManager!
    var transferCharacteristic:CBMutableCharacteristic!
    var dataToSend:NSData!
    var sendDataIndex:Int!
    var sendingEOM:Bool = false
    let MAX_TRANSFER_DATA_LENGTH:Int = 20
    
    @IBAction func sendData(sender: AnyObject) {
        println("\(peripheralManager)")
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: TRANSFER_SERVICE_UUID)]])
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textView.delegate = self
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        
    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        peripheralManager.stopAdvertising()
//        
//        super.viewWillDisappear(true)
//    }
//    
//    override func viewDidDisappear(animated: Bool) {
//        
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        dataToSend = textView.text.dataUsingEncoding(NSUTF8StringEncoding)
        
        sendDataIndex = 0
        
        transferData()
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
            }
            
            return
        }
        
        if sendDataIndex >= dataToSend.length {
            println("BLAHBLAH")
            return
        }
        
        var didSend:Bool = true
        
        while(didSend) {
            println("dataToSend: \(NSString(data: dataToSend, encoding: NSUTF8StringEncoding)!), sendDataIndex: \(sendDataIndex)")
            var amountToSend:Int = dataToSend.length - sendDataIndex
            println("amountToSend \(amountToSend)")
            
            if amountToSend > MAX_TRANSFER_DATA_LENGTH {
                amountToSend = MAX_TRANSFER_DATA_LENGTH
            }

            var chunk = NSData(bytes: dataToSend.bytes + sendDataIndex, length: amountToSend)
            println("chunk: \(NSString(data: chunk, encoding: NSUTF8StringEncoding)!)")
            println("Right here bae: transferData()")
            didSend = peripheralManager.updateValue(chunk, forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
            
            if !didSend {
                println("didnotsend")
                return;
            }
            
            var stringFromData = NSString(data: chunk, encoding: NSUTF8StringEncoding)
            println("Sent" + stringFromData!)
            
            sendDataIndex = sendDataIndex + amountToSend
            
            if sendDataIndex >= dataToSend.length {
                
                println("doing it")
                
                sendingEOM = true
                
                var eomSent = peripheralManager.updateValue("EOM".dataUsingEncoding(NSUTF8StringEncoding), forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
                
                if eomSent {
                    sendingEOM = false
                    println("send EOM")
                }
                
                return
            }
        }
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager!) {
        println("ready to transfer")
        transferData()
    }
    
    func textViewDidChange(textView: UITextView) {
        println("textviewchange")
        if peripheralManager.isAdvertising {
//            peripheralManager.stopAdvertising()
            println("here")
        }
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
