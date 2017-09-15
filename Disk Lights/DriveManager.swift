//
//  DriveManager.swift
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 4/18/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

import Foundation
import Cocoa

class DriveManager {
    
    var driveNodes: [String:DriveData] = [:]
    var drivesEnabled: [String:Bool] = [:]
    
    private var queue = DispatchQueue(label: "driveNodesQueue")
    
    private init() {
        initIOKit()
    }
    
    static let sharedInstance = DriveManager()
    
    func refresh() {
        
        guard let drives = refresh_drive_stats().takeRetainedValue() as? [[String:AnyObject]] else {
            return
        }
        
        var updatedDriveNodes: [String:DriveData] = [:]
        
        for drive in drives {
            guard let name = drive["name"] as? String,
                let serialNo = drive["serial_no"] as? String,
                let bytesRead = drive["bytes_read"] as? UInt64,
                let bytesWritten = drive["bytes_written"] as? UInt64 else {
                    continue
            }
            
            var driveNodeData = DriveData(name: name,
                                          serialNo: serialNo,
                                          bytesRead: bytesRead,
                                          bytesWritten: bytesWritten)
            
            if let curDriveNodeData = DriveManager.sharedInstance.driveNodes[serialNo] {
                driveNodeData.prevBytesRead = curDriveNodeData.bytesRead
                driveNodeData.prevBytesWritten = curDriveNodeData.bytesWritten
            }
            
            driveNodeData.updateRates()
            
            updatedDriveNodes[serialNo] = driveNodeData
            
           // print("Read rate: \(driveNodeData.readRate) bytes per sec")
            //print("Write rate: \(driveNodeData.writeRate) bytes per sec")
        }
        
        queue.sync {
            DriveManager.sharedInstance.driveNodes = updatedDriveNodes
        }
    }
}

