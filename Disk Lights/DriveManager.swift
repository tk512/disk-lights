//
//  DriveManager.swift
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 4/18/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

import Foundation

final class DriveManager {
    private init() { }
    
    static let sharedInstance: DriveManager = DriveManager()
    
    // Drive node data by serial no as key
    var driveNodes: [String:DriveData] = [:]
}
