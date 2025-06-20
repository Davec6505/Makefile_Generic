#ifndef LINKLIST_H
#define LINKLIST_H

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>

// structs
struct node{
    int data;
    struct node *next;
};

// Function prototype for linklist
void linklist(struct node *start);


#endif // LINKLIST_H