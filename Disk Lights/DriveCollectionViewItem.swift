//
//  DriveCollectionViewItem.swift
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 4/19/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

import Cocoa

class DriveCollectionViewItem: NSCollectionViewItem {

    @IBOutlet weak var checkedButton: NSButton!
    
    @IBAction func clickedDrive(_ sender: Any) {
        checkedButton.performClick(_: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
    }
    override func viewDidAppear() {
        super.viewDidAppear()
    }
}
