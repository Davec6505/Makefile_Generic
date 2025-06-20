#include "linklist.h"


struct node *create_sll(struct node *start);
struct node *display_sll(struct node *start);
struct node *insert_beg(struct node *start);
struct node *insert_end(struct node *start);
struct node *insert_after(struct node *start);
struct node *insert_before(struct node *start);
struct node *delete_beg(struct node *start);
struct node *delete_end(struct node *start);
struct node *delete_after(struct node *start);
struct node *delete_before(struct node *start);
struct node *delete_node(struct node *start);
struct node *search_node(struct node *start);
struct node *sort_list(struct node *start);
struct node *reverse_list(struct node *start);
struct node *merge_lists(struct node *start1, struct node *start2);
struct node *split_list(struct node *start);
struct node *copy_list(struct node *start);
struct node *count_nodes(struct node *start);
struct node *clear_list(struct node *start);
struct node *delete_all(struct node *start);



void linklist(struct node *start) {
    int option;
    do {
        printf("\n\n***** MAIN MENU *****");
        printf("\n 1: Create a list");
        printf("\n 2: Display a list");
        printf("\n 3: Insert at the beginning");
        printf("\n 4: Insert at the end");
        printf("\n 5: Insert after a node");
        printf("\n 6: Insert before a node");
        printf("\n 7: Delete from the beginning");
        printf("\n 8: Delete from the end");
        printf("\n 9: Delete after a node");
        printf("\n10: Delete before a node");
        printf("\n11: Delete a specific node");
        printf("\n12: Search for a node");
        printf("\n13: Sort the list");
        printf("\n14: Reverse the list");
        printf("\n15: Exit");
        printf("\n\nEnter your option: ");
        scanf("%d", &option);

        switch (option) {
            case 1: start = create_sll(start); break;
            case 2: start = display_sll(start); break;
            case 3: start = insert_beg(start); break;
            case 4: start = insert_end(start); break;
            case 5: start = insert_after(start); break;
            case 6: start = insert_before(start); break;
            case 7: start = delete_beg(start); break;
            case 8: start = delete_end(start); break;
            case 9: start = delete_after(start); break;
            case 10: start = delete_before(start); break;
            case 11: start = delete_node(start); break;
            case 12: start = search_node(start); break;
            case 13: start = sort_list(start); break;
            case 14: start = reverse_list(start); break;
            case 15: printf("\nExiting program.\n"); break;
            default: printf("\nInvalid option. Try again.\n");
        }
    } while (option != 15);
}

struct node *create_sll(struct node *start) {
    struct node *new_node, *ptr;
    int num;
    printf("\nEnter -1 to end the list");
    printf("\nEnter the data: ");
    scanf("%d", &num);
    while (num != -1) {
        new_node = (struct node *)malloc(sizeof(struct node));
        new_node->data = num;
        new_node->next = NULL;
        if (start == NULL) {
            start = new_node;
        } else {
            ptr = start;
            while (ptr->next != NULL) {
                ptr = ptr->next;
            }
            ptr->next = new_node;
        }
        printf("\nEnter the data: ");
        scanf("%d", &num);
    }
    return start;
}

struct node *display_sll(struct node *start) {
    struct node *ptr;
    if (start == NULL) {
        printf("\nList is empty.");
        return start;
    }
    ptr = start;
    printf("\nThe elements in the list are: ");
    while (ptr != NULL) {
        printf("%d -> ", ptr->data);
        ptr = ptr->next;
    }
    printf("NULL\n");
    return start;
}

struct node *insert_beg(struct node *start) {
    struct node *new_node;
    new_node = (struct node *)malloc(sizeof(struct node));
    printf("\nEnter the data to insert at the beginning: ");
    scanf("%d", &new_node->data);
    new_node->next = start;
    start = new_node;
    return start;
}

struct node *insert_end(struct node *start) {
    struct node *new_node, *ptr;
    new_node = (struct node *)malloc(sizeof(struct node));
    printf("\nEnter the data to insert at the end: ");
    scanf("%d", &new_node->data);
    new_node->next = NULL;
    if (start == NULL) {
        start = new_node;
    } else {
        ptr = start;
        while (ptr->next != NULL) {
            ptr = ptr->next;
        }
        ptr->next = new_node;
    }
    return start;
}

struct node *insert_after(struct node *start) {
    struct node *new_node, *ptr;
    int val;
    printf("\nEnter the value after which to insert: ");
    scanf("%d", &val);
    ptr = start;
    while (ptr != NULL && ptr->data != val) {
        ptr = ptr->next;
    }
    if (ptr == NULL) {
        printf("\nValue not found.");
    } else {
        new_node = (struct node *)malloc(sizeof(struct node));
        printf("\nEnter the data to insert: ");
        scanf("%d", &new_node->data);
        new_node->next = ptr->next;
        ptr->next = new_node;
    }
    return start;
}

struct node *insert_before(struct node *start) {
    struct node *new_node, *ptr, *preptr;
    int val;
    printf("\nEnter the value before which to insert: ");
    scanf("%d", &val);
    new_node = (struct node *)malloc(sizeof(struct node));
    printf("\nEnter the data to insert: ");
    scanf("%d", &new_node->data);
    if (start->data == val) {
        new_node->next = start;
        start = new_node;
    } else {
        ptr = start;
        while (ptr != NULL && ptr->data != val) {
            preptr = ptr;
            ptr = ptr->next;
        }
        if (ptr == NULL) {
            printf("\nValue not found.");
        } else {
            preptr->next = new_node;
            new_node->next = ptr;
        }
    }
    return start;
}

struct node *delete_beg(struct node *start) {
    struct node *ptr;
    if (start == NULL) {
        printf("\nList is empty.");
    } else {
        ptr = start;
        start = start->next;
        free(ptr);
    }
    return start;
}

struct node *delete_end(struct node *start) {
    struct node *ptr, *preptr;
    if (start == NULL) {
        printf("\nList is empty.");
    } else if (start->next == NULL) {
        free(start);
        start = NULL;
    } else {
        ptr = start;
        while (ptr->next != NULL) {
            preptr = ptr;
            ptr = ptr->next;
        }
        preptr->next = NULL;
        free(ptr);
    }
    return start;
}

struct node *delete_after(struct node *start) {
    struct node *ptr, *temp;
    int val;
    printf("\nEnter the value after which to delete: ");
    scanf("%d", &val);
    ptr = start;
    while (ptr != NULL && ptr->data != val) {
        ptr = ptr->next;
    }
    if (ptr == NULL || ptr->next == NULL) {
        printf("\nNo node to delete.");
    } else {
        temp = ptr->next;
        ptr->next = temp->next;
        free(temp);
    }
    return start;
}

struct node *delete_before(struct node *start) {
    struct node *ptr, *preptr, *temp;
    int val;
    preptr = NULL;
    printf("\nEnter the value before which to delete: ");
    scanf("%d", &val);
    if (start == NULL || start->data == val) {
        printf("\nNo node to delete.");
    } else if (start->next->data == val) {
        temp = start;
        start = start->next;
        free(temp);
    } else {
        ptr = start;
        while (ptr->next != NULL && ptr->next->data != val) {
            preptr = ptr;
            ptr = ptr->next;
        }
        if (ptr->next == NULL) {
            printf("\nValue not found.");
        } else {
            temp = ptr;
            preptr->next = ptr->next;
            free(temp);
        }
    }
    return start;
}

struct node *delete_node(struct node *start) {
    struct node *ptr, *preptr;
    int val;
    printf("\nEnter the value of the node to delete: ");
    scanf("%d", &val);
    if (start == NULL) {
        printf("\nList is empty.");
    } else if (start->data == val) {
        ptr = start;
        start = start->next;
        free(ptr);
    } else {
        ptr = start;
        while (ptr != NULL && ptr->data != val) {
            preptr = ptr;
            ptr = ptr->next;
        }
        if (ptr == NULL) {
            printf("\nValue not found.");
        } else {
            preptr->next = ptr->next;
            free(ptr);
        }
    }
    return start;
}

struct node *search_node(struct node *start) {
    struct node *ptr;
    int val, pos = 1;
    printf("\nEnter the value to search: ");
    scanf("%d", &val);
    ptr = start;
    while (ptr != NULL) {
        if (ptr->data == val) {
            printf("\nValue found at position %d.", pos);
            return start;
        }
        ptr = ptr->next;
        pos++;
    }
    printf("\nValue not found.");
    return start;
}

struct node *sort_list(struct node *start) {
    struct node *ptr1, *ptr2;
    int temp;
    if (start == NULL) {
        printf("\nList is empty.");
        return start;
    }
    for (ptr1 = start; ptr1->next != NULL; ptr1 = ptr1->next) {
        for (ptr2 = ptr1->next; ptr2 != NULL; ptr2 = ptr2->next) {
            if (ptr1->data > ptr2->data) {
                temp = ptr1->data;
                ptr1->data = ptr2->data;
                ptr2->data = temp;
            }
        }
    }
    printf("\nList sorted successfully.");
    return start;
}

struct node *reverse_list(struct node *start) {
    struct node *prev = NULL, *current = start, *next;
    while (current != NULL) {
        next = current->next;
        current->next = prev;
        prev = current;
        current = next;
    }
    start = prev;
    printf("\nList reversed successfully.");
    return start;
}

struct node *merge_lists(struct node *start1, struct node *start2) {
    struct node *ptr;
    if (start1 == NULL) return start2;
    if (start2 == NULL) return start1;
    ptr = start1;
    while (ptr->next != NULL) {
        ptr = ptr->next;
    }
    ptr->next = start2;
    printf("\nLists merged successfully.");
    return start1;
}

struct node *split_list(struct node *start) {
    printf("\nSplit list functionality not implemented yet.");
    return start;
}

struct node *copy_list(struct node *start) {
    struct node *new_list = NULL, *ptr, *new_node, *last;
    if (start == NULL) {
        printf("\nList is empty.");
        return new_list;
    }
    ptr = start;
    while (ptr != NULL) {
        new_node = (struct node *)malloc(sizeof(struct node));
        new_node->data = ptr->data;
        new_node->next = NULL;
        if (new_list == NULL) {
            new_list = new_node;
            last = new_node;
        } else {
            last->next = new_node;
            last = new_node;
        }
        ptr = ptr->next;
    }
    printf("\nList copied successfully.");
    return new_list;
}

struct node *count_nodes(struct node *start) {
    struct node *ptr = start;
    int count = 0;
    while (ptr != NULL) {
        count++;
        ptr = ptr->next;
    }
    printf("\nNumber of nodes in the list: %d", count);
    return start;
}

struct node *clear_list(struct node *start) {
    struct node *ptr;
    while (start != NULL) {
        ptr = start;
        start = start->next;
        free(ptr);
    }
    printf("\nList cleared successfully.");
    return start;
}

struct node *delete_all(struct node *start) {
    return clear_list(start);
}


