#include <stdio.h>
#include <stdlib.h>

typedef struct node {
    int data;
    struct node* next;
}node;

node* top;

void init_stack()
{
    top = NULL;
}

int is_empty()
{
    if(top == NULL) return 1;
    return 0;
}

void push(int x)
{
    node* n = (node*)malloc(sizeof(node));
    n->data = x;
    n->next = top;
    top = n;
}

int pop()
{
    if(!is_empty())
    {
        node* n = top;
        top = top->next;
        return n->data;
    }
    return -1;
}

void free_stack()
{
    node *n;
    while(top != NULL)
    {
        n = top;
        top = top->next;
        free(n);
    }
}
