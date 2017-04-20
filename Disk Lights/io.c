//
//  io.c - Integration with IOKit to read disk drive usage
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 4/9/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

#include "io.h"

#include <sys/param.h>
#include <sys/sysctl.h>

#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/storage/IOBlockStorageDriver.h>
#include <IOKit/storage/IOMedia.h>
#include <IOKit/IOBSD.h>
#include <err.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "util.h"

static mach_port_t host_priv_port;
static mach_port_t masterPort;
static IONotificationPortRef notifyPort;

static void enumerate_io_devices();
static void register_device(io_registry_entry_t drive);
static void unregister_device(io_registry_entry_t drive);

void initIOKit() {
    /*
     * Get the Mach private port.
     */
    host_priv_port = mach_host_self();
    
    /*
     * Get the I/O Kit communication handle.
     */
    IOMasterPort(bootstrap_port, &masterPort);
    notifyPort = IONotificationPortCreate(masterPort);
    
    /*
     * Enumerate available block IO devices
     */
    enumerate_io_devices();
}


static void device_removed(void* context, io_iterator_t drivelist) {
    io_registry_entry_t removedDevice;
    while ((removedDevice = IOIteratorNext(drivelist))) {
        unregister_device(removedDevice);
        IOObjectRelease(removedDevice);
    }
}

static void device_added(void* context, io_iterator_t drivelist) {
    io_registry_entry_t addedDevice;
    while ((addedDevice = IOIteratorNext(drivelist))) {
        register_device(addedDevice);
        IOObjectRelease(addedDevice);
    }
}


static void enumerate_io_devices() {
    // Get an iterator for IOMedia objects
    CFMutableDictionaryRef match = IOServiceMatching("IOMedia");
    CFDictionaryAddValue(match, CFSTR(kIOMediaWholeKey), kCFBooleanTrue);
    
    CFRetain(match); // For our first call toIOServiceAddMatchingNotification
    CFRetain(match); // For the second call
    
    io_iterator_t drivelist_added;
    io_iterator_t drivelist_removed;
    
    CFRunLoopSourceRef rls = IONotificationPortGetRunLoopSource(notifyPort);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
    
    // Add matching notification for devices being added
    kern_return_t status = IOServiceAddMatchingNotification(notifyPort,
                                                            kIOFirstMatchNotification,
                                                            match,
                                                            &device_added,
                                                            NULL,
                                                            &drivelist_added);
    if(status != kIOReturnSuccess)
        errx(1, "Could not add matching notification for new devices");
    
    // Initial run to get current drives
    device_added(NULL, drivelist_added);
    
    /*
     * Add matching notification for devices being removed
     */
    status = IOServiceAddMatchingNotification(notifyPort,
                                              kIOTerminatedNotification,
                                              match,
                                              &device_removed,
                                              NULL,
                                              &drivelist_removed);
    if(status != kIOReturnSuccess)
        errx(1, "Could not add matching notification for removed devices");
    
    // Initial run to get removed drives
    device_removed(NULL, drivelist_removed);
}

static char *get_drive_identifier(io_registry_entry_t drive,
                                  io_registry_entry_t storage_device,
                                  bool is_usb)
{
    io_registry_entry_t gp;
    kern_return_t status = IORegistryEntryGetParentEntry(storage_device, kIOServicePlane, &gp);
    if(status != kIOReturnSuccess) {
        printf("ERROR");
    }

    // First see if this is a removable USB drive
    if(is_usb && status == kIOReturnSuccess && IOObjectConformsTo(gp, "IOSCSIBlockCommandsDevice")) {
        
        // The path to find a USB driver nub which contains vendor/device/serialstr
        io_registry_entry_t grandparent, greatgrandparent, nub;
        kern_return_t status_gp = IORegistryEntryGetParentEntry(gp, kIOServicePlane, &grandparent),
        status_ggp = IORegistryEntryGetParentEntry(grandparent, kIOServicePlane, &greatgrandparent),
        status_nub = IORegistryEntryGetParentEntry(greatgrandparent, kIOServicePlane, &nub);
        
        if(status_gp == kIOReturnSuccess && status_ggp == kIOReturnSuccess
           && status_nub == kIOReturnSuccess && IOObjectConformsTo(greatgrandparent, "IOUSBMassStorageDriver")) {
            
            CFDictionaryRef nub_properties;
            status = IORegistryEntryCreateCFProperties(nub,
                                                       (CFMutableDictionaryRef *)&nub_properties,
                                                       kCFAllocatorDefault,
                                                       kNilOptions);
            if(status == kIOReturnSuccess) {
                CFDictionaryRef device_info = CFDictionaryGetValue(nub_properties, CFSTR("USB Device Info"));
                if(device_info) {
                    return CFStringCopyUTF8String(CFDictionaryGetValue(
                                                                       device_info,
                                                                       CFSTR("kUSBSerialNumberString")));
                }
            }
            CFRelease(nub_properties);
        }
        
        return NULL;
    }
    
    // Then we follow and assume this is regular AHCI based block storage
    if (status == kIOReturnSuccess && IOObjectConformsTo(gp, "IOAHCIBlockStorageDriver")) {
        CFDictionaryRef sata_properties;
        status = IORegistryEntryCreateCFProperties(gp,
                                                   (CFMutableDictionaryRef *)&sata_properties,
                                                   kCFAllocatorDefault,
                                                   kNilOptions);
        if(status == kIOReturnSuccess) {
            CFStringRef serial_no = CFDictionaryGetValue(sata_properties, CFSTR("Serial Number"));
            if(serial_no) {
                return CFStringCopyUTF8String(serial_no);
            }
        }
        
        CFRelease(sata_properties);
        return NULL;
    }
    
    // Last option, use IOMedia's UUID as serial number
    io_iterator_t children;
    
    status = IORegistryEntryGetChildIterator(drive, kIOServicePlane, &children);
    if(status != kIOReturnSuccess)
        return NULL;
    
    io_registry_entry_t child;
    while((child = IOIteratorNext(children)) != (io_registry_entry_t) NULL) {
        if(IOObjectConformsTo(child, "IOPartitionScheme")) {
            io_registry_entry_t partition;
            status = IORegistryEntryGetChildEntry(child, kIOServicePlane, &partition);
            if(status == kIOReturnSuccess && IOObjectConformsTo(partition, "IOMedia")) {
                CFDictionaryRef usb_properties;
                status = IORegistryEntryCreateCFProperties(partition,
                                                           (CFMutableDictionaryRef *)&usb_properties,
                                                           kCFAllocatorDefault,
                                                           kNilOptions);
                if(status == kIOReturnSuccess) {
                    CFStringRef uuid = CFDictionaryGetValue(usb_properties, CFSTR("UUID"));
                    return CFStringCopyUTF8String(uuid);
                }
                
                CFRelease(usb_properties);
            }
        }
    }
    return NULL;
}

io_registry_entry_t get_storage_device(io_registry_entry_t drive, io_registry_entry_t *parent) {
    
    /* Get drive's parent, which must subclass IOBlockStorageDriver */
    kern_return_t status = IORegistryEntryGetParentEntry(drive, kIOServicePlane, parent);
    
    if (status != kIOReturnSuccess || !IOObjectConformsTo(*parent, "IOBlockStorageDriver")) {
        return 0;
    }
    
    // Get parent's parent, which must be a subclass of IOBlockStorageDevice
    io_registry_entry_t storage_device;
    status = IORegistryEntryGetParentEntry(*parent, kIOServicePlane, &storage_device);
    if (status != kIOReturnSuccess || !IOObjectConformsTo(storage_device, "IOBlockStorageDevice")) {
        return 0;
    }
    return storage_device;
}

static bool is_device_usb(io_registry_entry_t storage_device)
{
    kern_return_t status;
    CFDictionaryRef storage_device_properties;
    status = IORegistryEntryCreateCFProperties(storage_device,
                                               (CFMutableDictionaryRef *) &storage_device_properties,
                                               kCFAllocatorDefault, kNilOptions);
    
    CFDictionaryRef characteristics = (CFDictionaryRef)CFDictionaryGetValue(storage_device_properties, CFSTR(kIOPropertyProtocolCharacteristicsKey));
    if(status != kIOReturnSuccess || !characteristics) {
        return false;
    }
    
    // Get physical interconnect string to determine PCI, USB etc.
    CFStringRef physical_interconnect = (CFStringRef)CFDictionaryGetValue(characteristics, CFSTR(kIOPropertyPhysicalInterconnectTypeKey));
    if(!physical_interconnect) {
        return false;
    }
    
    bool ret = CFStringCompare(physical_interconnect, CFSTR("USB"), 0) ? false : true;
    CFRelease(storage_device_properties);
    return ret;
}

static void register_device(io_registry_entry_t drive)
{
    kern_return_t status;
    io_registry_entry_t parent;
    io_registry_entry_t storage_device = get_storage_device(drive, &parent);
    
    if(!storage_device)
        return;

    // Get the name of the media type e.g. APPLE SSD or Patriot Memory etc.
    io_name_t name;
    status = IORegistryEntryGetNameInPlane(drive, kIOServicePlane, name);
    if(status != kIOReturnSuccess) {
        return;
    }

    // Get drive identifier aka serial number along with USB status
    bool is_usb = is_device_usb(storage_device);
    char *serial_no = get_drive_identifier(drive, storage_device, is_usb);
    if(serial_no != NULL) {
        drive_node_t *existing_drive = find_drive_node(serial_no);
        if(existing_drive == NULL) {
            push_drive_node(parent, serial_no, name);
        }
    }
}

static void unregister_device(io_registry_entry_t drive)
{
    io_registry_entry_t parent;
    io_registry_entry_t storage_device = get_storage_device(drive, &parent);
    
    bool is_usb = is_device_usb(storage_device);
    
    // Get drive identifier aka serial number
    char *serial_no = get_drive_identifier(drive, storage_device, is_usb);
    if(serial_no != NULL) {
        drive_node_t *ptr = find_drive_node(serial_no);
        if(ptr != NULL) {
            delete_drive_node(ptr);
            
            drive_node_t *test = drive_nodes_head;
            while(test != NULL) {
                test = test->next;
            }
            
        }
    }
}

/*
 * Get drive stats and return as CFArrayRef
 */
CFDictionaryRef build_drive_cfdictionary(drive_node_t *drive)
{
    CFStringRef keys[4];
    void *values[4];
    
    keys[0] = CFSTR("serial_no");
    values[0] = (void*) CFStringCreateWithCString(kCFAllocatorDefault, drive->serial_no, kCFStringEncodingASCII);
    keys[1] = CFSTR("name");
    values[1] = (void*)CFStringCreateWithCString(kCFAllocatorDefault, drive->name, kCFStringEncodingASCII);
    
    keys[2] = CFSTR("bytes_read");
    values[2] = (void*)CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt64Type, &drive->bytes_read);
    
    keys[3] = CFSTR("bytes_written");
    values[3] = (void*)CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt64Type, &drive->bytes_written);
    
    CFDictionaryRef dict = CFDictionaryCreate(NULL, (const void **)keys, (const void **)values, 4, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    return dict;
}

#define MAX_DRIVES 10

CFArrayRef refresh_drive_stats()
{
    CFDictionaryRef drives[MAX_DRIVES];
    
    drive_node_t *ptr = drive_nodes_head;
    int cnt = 0;
    while(ptr != NULL) {
        
        CFDictionaryRef properties, statistics;
        CFNumberRef number;
        u_int64_t value;
        
        kern_return_t status = IORegistryEntryCreateCFProperties(ptr->driver, (CFMutableDictionaryRef *) &properties, kCFAllocatorDefault, kNilOptions);
        if(status == kIOReturnSuccess) {
            
            statistics = CFDictionaryGetValue(properties, CFSTR(kIOBlockStorageDriverStatisticsKey));
            if(statistics) {
                
                if ((number = (CFNumberRef) CFDictionaryGetValue(statistics, CFSTR(kIOBlockStorageDriverStatisticsBytesReadKey)))) {
                    
                    CFNumberGetValue(number, kCFNumberSInt64Type, &value);
                    ptr->bytes_read = value;
                }
                if ((number = (CFNumberRef) CFDictionaryGetValue(statistics, CFSTR(kIOBlockStorageDriverStatisticsBytesWrittenKey)))) {
                    
                    CFNumberGetValue(number, kCFNumberSInt64Type, &value);
                    ptr->bytes_written = value;
                }
            }
            
            drives[cnt++] = build_drive_cfdictionary(ptr);
            
            CFRelease(properties);
        }
        
        ptr = ptr->next;
    }
    
    CFArrayRef anArray = CFArrayCreate(NULL, (void *)drives, cnt, &kCFTypeArrayCallBacks);
    
    return anArray;
}


