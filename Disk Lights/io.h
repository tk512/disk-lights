//
//  io.h
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 4/9/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

#ifndef io_h
#define io_h

#include <stdio.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/storage/IOBlockStorageDriver.h>
#include <IOKit/storage/IOMedia.h>
#include <IOKit/IOBSD.h>

#include "drive_nodes.h"

void initIOKit();

void test();

CFArrayRef refresh_drive_stats();

#endif /* io_h */
