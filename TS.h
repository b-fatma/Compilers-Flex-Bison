#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct
{
  char name[20];
  char code[20];
  char type[20];
  float val;
 } element;

typedef struct
{ 
  char name[20];
  char type[20];
} elt;


typedef struct liste_element{
  element data;
  struct liste_element* svt;
}liste_element;

typedef struct liste_elt{
  elt data;
  struct liste_elt* svt;
}liste_elt;

liste_element *liste;
liste_elt *listes;
liste_elt *listem; 

void initialisation()
{
  liste = NULL;
  listes = NULL;
  listem = NULL;
  printf("TS INITIALISEE\n");
}

liste_element* inserer_element(liste_element* tete, liste_element* e)
{
  e->svt = tete;
  return e;
}

liste_elt* inserer_elt(liste_elt* tete, liste_elt* e)
{
  e->svt = tete;
  return e;
}

liste_element* element_existe(liste_element* tete, char name[])
{
  liste_element* node = tete;
  while(node != NULL)
  {
    if(strcmp(node->data.name, name) == 0) return node;
    node = node->svt;
  }
  return NULL;
}

liste_elt* elt_existe(liste_elt* tete, char name[])
{
  liste_elt* node = tete;
  while(node != NULL)
  {
    if(strcmp(node->data.name, name) == 0) return node;
    node = node->svt;
  }
  return NULL;
}

void inserer (char entite[], char code[], char type[], float val, int y)
{
  liste_element * node = NULL;
  liste_elt * e = NULL;
  switch(y)
  {
    case 0:
      node = (liste_element*) malloc(sizeof(struct liste_element)); 
      node->data.val = val;
      strcpy(node->data.name, entite);
      strcpy(node->data.code, code);
	    strcpy(node->data.type, type);
      liste = inserer_element(liste, node);
      break;

    case 1:
      e = (liste_elt*) malloc(sizeof(liste_elt));
      strcpy(e->data.name, entite);
      strcpy(e->data.type, code);
      listem = inserer_elt(listem, e);
      break;

    case 2:
      e = (liste_elt*) malloc(sizeof(liste_elt));
      strcpy(e->data.name, entite);
      strcpy(e->data.type, code);
      listes = inserer_elt(listes, e);
      break;
    default:
      break;
  }
}

void rechercher(char entite[], char code[], char type[], float val, int y)
{
  switch(y)
  {
    case 0:
      if(element_existe(liste, entite) != NULL) 
        printf("l'entite existe deja\n");
      else 
        inserer(entite, code, type, val, 0);
      break;

    case 1:
      if(elt_existe(listem, entite)) 
        printf("l'entite existe deja\n");
      else 
        inserer(entite, code, type, val, 1);
      break;

    case 2:
      if(elt_existe(listes, entite)) 
        printf("l'entite existe deja\n");
      else 
        inserer(entite, code, type, val, 2);
      break;
  }
}

void inserer_type(char entite[], char type[])
{
  liste_element * node = element_existe(liste, entite);
  // printf("%s\n", entite);
  if(node != NULL) strcpy(node->data.type, type);
}

int double_declaration(char entite[])
{
  liste_element* node = element_existe(liste, entite);
  if(node != NULL && strcmp(node->data.type, "") == 0) return 0;
  return -1;
}

void type_element(char entite[], char* type)
{
  liste_element * node = element_existe(liste, entite);
  if(node != NULL) 
  {
    strcpy(type, node->data.type); 
  }
}

// void initialiser_element(char entite[], float val)
// {
//   liste_element * node = element_existe(liste, entite);
//   if(node != NULL) node->data.val = val;
// }

void afficher()
{

  printf("/***************liste des symboles IDF*************/\n");
  printf("____________________________________________________________________\n");
  printf("\t| Nom_Entite |  Code_Entite   | Type_Entite      | Val_Entite\n");
  printf("____________________________________________________________________\n");

  liste_element* node = liste;
  while(node != NULL)
  {
    printf("\t|%11s |%15s | %16s | %12f\n", node->data.name, node->data.code, node->data.type, node->data.val);
    node = node->svt;
  }


  liste_elt* node_elt;
  printf("\n/***************liste des symboles mots cles*************/\n");
  printf("_____________________________________\n");
  printf("\t| NomEntite |  CodeEntite | \n");
  printf("_____________________________________\n");

  node_elt = listem;
  while(node_elt != NULL)
  {
    printf("\t|%10s |%12s | \n",node_elt->data.name, node_elt->data.type);
    node_elt = node_elt->svt;
  }


  printf("\n/***************liste des symboles separateurs*************/\n");
  printf("_____________________________________\n");
  printf("\t| NomEntite |  CodeEntite | \n");
  printf("_____________________________________\n");
  
  node_elt = listes;
  while(node_elt != NULL)
  {
    printf("\t|%10s |%12s | \n",node_elt->data.name, node_elt->data.type);
    node_elt = node_elt->svt;
  }
}
