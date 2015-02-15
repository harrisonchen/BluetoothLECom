//
//  BLECentralDelegate.swift
//  BluetoothLECom
//
//  Created by Harrison Chen on 2/14/15.
//  Copyright (c) 2015 StudentGlue. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLECentralDelegate {
    func didDiscoverPeripheral(peripheral: CBPeripheral!)
}