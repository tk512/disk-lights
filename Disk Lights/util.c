//
//  util.c
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 4/16/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

#include "util.h"

char * CFStringCopyUTF8String(CFStringRef aString) {
    if(aString == NULL) {
        return NULL;
    }
    
    CFIndex length = CFStringGetLength(aString);
    CFIndex maxSize = CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8) + 1;
    char *buffer = (char *)malloc(maxSize);
    if (CFStringGetCString(aString, buffer, maxSize, kCFStringEncodingUTF8)) {
        return buffer;
    }
    free(buffer); // If we failed
    return NULL;
}
