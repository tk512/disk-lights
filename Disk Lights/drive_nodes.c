//
//  drive_nodes.c
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 4/17/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

#include "drive_nodes.h"

drive_node_t *drive_nodes_head = NULL;

void push_drive_node(uint32_t driver, char *serial_no, char *name)
{
    drive_node_t *ptr;
    ptr = calloc(1, sizeof(drive_node_t));
    
    ptr->driver = driver;
    ptr->serial_no = serial_no;
    ptr->name = calloc(strlen(name) + 1, sizeof(char));
    strncpy(ptr->name, name, strlen(name));
    
    ptr->next = drive_nodes_head;
    drive_nodes_head = ptr;
}

drive_node_t *find_drive_node(char *serial_no)
{
    drive_node_t *ptr = drive_nodes_head;
    while(ptr != NULL) {
        if(strncmp(serial_no, ptr->serial_no, strlen(serial_no)) == 0)
            return ptr;
        ptr = ptr->next;
    }
    return NULL;
}

void delete_drive_node(drive_node_t *node)
{
    drive_node_t *temp, *prev;
    temp = node;
    prev = drive_nodes_head;
    
    if(temp == prev) {
        drive_nodes_head = drive_nodes_head->next;
    } else {
        while(prev->next != temp) {
            prev = prev->next;
        }
        prev->next = temp->next;
    }
    free(temp);
}

void debug_print_drives()
{
    drive_node_t *ptr = drive_nodes_head;
    while(ptr != NULL) {
        printf("[drive_node_t with serial_no %s, entry %ud\n", ptr->serial_no, ptr->driver);
        ptr = ptr->next;
    }
}
