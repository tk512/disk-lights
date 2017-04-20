//
//  drive_nodes.h
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 4/17/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

#ifndef drive_nodes_h
#define drive_nodes_h

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

typedef struct drive_node {
    uint32_t driver;
    char *name;
    char *serial_no;
    u_int64_t bytes_read;
    u_int64_t bytes_written;
    struct drive_node *next;
} drive_node_t;

extern drive_node_t *drive_nodes_head;

drive_node_t *find_drive_node(char *serial_no);
void push_drive_node(uint32_t driver, char *serial_no, char *name);
void delete_drive_node(drive_node_t *node);

#endif /* drive_nodes_h */
