//
//  DriveNodeData.swift
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 4/18/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

import Foundation

struct DriveData {
    let name, serialNo: String
    let bytesRead, bytesWritten: UInt64
    
    var prevBytesRead: UInt64 = 0
    var prevBytesWritten: UInt64 = 0
    
    var prevReadRate: UInt64 = 0
    var readRate: UInt64 = 0
    
    var prevWriteRate: UInt64 = 0
    var writeRate: UInt64 = 0
    
    init(name: String, serialNo: String, bytesRead: UInt64, bytesWritten: UInt64) {
        self.name = name
        self.serialNo = serialNo
        self.bytesRead = bytesRead
        self.bytesWritten = bytesWritten
    }
    
    mutating func updateRates() {
        prevReadRate = readRate
        readRate = bytesRead - (prevBytesRead != 0 ? prevBytesRead : bytesRead)
        
        prevWriteRate = writeRate
        writeRate = bytesWritten - (prevBytesWritten != 0 ? prevBytesWritten : bytesWritten)
    }
}
