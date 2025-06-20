
#include "linklist.h"


struct node *start = NULL;

struct node *create_sll(struct node *start);
struct node *display_sll(struct node *start);

void linklist(){
int option;

 do{
    printf("\n\n***** MAIN MENU *****");
    printf("\n 1: Create a list");
    printf("\n 2: Display a list");

    printf("\n\n Enter your option: ");
    scanf("%d",&option);
    switch(option){
        case 1: start = create_sll(start);
            printf("\n SINGLEY LINKED LIST CREATED");
            break;
        case 2: start = display_sll(start);
            break;
    }
 }while(option != 13);

}

struct node *create_sll(struct node *start){
  printf("\ncreating ...");
  return start;
}

struct node *display_sll(struct node *start){
 return start;
}
