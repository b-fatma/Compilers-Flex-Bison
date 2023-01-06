#include <stdio.h>
#include <stdlib.h>

typedef struct node {
    int data;
    node* next;
}node;

typedef struct stack{
    node* head;
}stack;

stack pile;

void init_stack()
{
    pile = (stack)malloc(sizeof(stack));
    pile.head = NULL;
}

int is_empty()
{
    if(pile.head == NULL) return 1;
    return 0;
}

void add(int x)
{
    node * n = (node*)malloc(sizeof(node));
    n->data = x;
    n->next = pile.head;
    pile.head = n;
}

int remove()
{
    if(!is_empty(pile))
    {
    node * n = pile.head;
    pile.head = pile.head->next;
    return n->data;}
    return -1;
}