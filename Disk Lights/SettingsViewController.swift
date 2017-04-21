//
//  SettingsViewController.swift
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 4/9/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

import Cocoa
import CoreFoundation

class SettingsViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 100.0, height: 120.0)
        flowLayout.sectionInset = EdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        driveCollectionView.collectionViewLayout = flowLayout
        view.wantsLayer = true
        //driveCollectionView.layer?.backgroundColor = CGColor(
    }
    
    private var queue = DispatchQueue(label: "driveNodesQueue")
    
    @IBOutlet weak var driveCollectionView: NSCollectionView!
    @IBOutlet weak var testField: NSTextField!
    @IBOutlet weak var testLbl: NSTextField!
    
    @IBAction func testButton(_ sender: Any) {
        
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
            
            let driveNodeData = DriveData(name: name,
                                          serialNo: serialNo,
                                          bytesRead: bytesRead,
                                          bytesWritten: bytesWritten)
            
            updatedDriveNodes[serialNo] = driveNodeData
        }
        
        queue.sync {
            DriveManager.sharedInstance.driveNodes = updatedDriveNodes
            testField.stringValue = "\(DriveManager.sharedInstance.driveNodes)"
        }
    }
    
    @IBAction func quitButton(_ sender: Any) {
        exit(0)
    }
}

extension SettingsViewController : NSCollectionViewDataSource {
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: "DriveCollectionViewItem", for: indexPath)
        guard let collectionViewItem = item as? DriveCollectionViewItem else {return item}
        collectionViewItem.textField?.stringValue = "Disk \(indexPath)"
        return item
        
    }
}
