%{
	#include "projet.tab.h"
	#include "TS.h"
	#include "quad.h"
	#include "pile.h"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	extern nb_lignes;
	extern nb_col;
	extern nb_indent;
	extern YYSTYPE yylval;
%}
lettre_maj [A-Z]
lettre_min [a-z]
chiffre [0-9]
idf {lettre_maj}({lettre_min}|{chiffre})*
cmnt #.*
cst_char \'({lettre_maj}|{lettre_min})\'
unsigned_cst_int (0|[1-9][0-9]*)
signed_cst_int [+-](0|[1-9][0-9]*)
unsigned_cst_float (0|[1-9][0-9]*)\.[0-9]*
signed_cst_float ([+-](0|[1-9][0-9]*)\.[0-9]*)
%%
^[ ]*[^ \n]+  {     
					unsigned int cpt_indent(char* ligne) 
     				{
  					unsigned int cpt = 0 ;
  					unsigned int espace = 0;
  					while(*ligne == ' ')
  					{
						nb_col ++;
          				espace ++;
          				if(espace % 4 == 0) {cpt ++; espace = 0;}
      					ligne++;
  					}
					//l'indentation doit être multiple de 4
					if(espace != 0) printf("Erreur syntaxique, indentation illegale, ligne %d, colonne %d\n", nb_lignes, nb_col);
 					return cpt ;
				    }

					int dernier = yyleng - 1;
					int i;
               		int nb_indent_crt = cpt_indent(yytext);
					while ((dernier >= 0) && (yytext[dernier] != ' ')) {
            	    	unput(yytext[dernier]);
                		dernier-- ;
					}
			   		if(nb_indent_crt < nb_indent)
					{
						nb_indent = nb_indent_crt; 
						printf("DEDENT\n"); 
						//printf("%s", yytext); 
						return dedent;
					}
				    if(nb_indent_crt > nb_indent)
					{
						//que les indentations d'un seul niveau sont autorisées
						if(nb_indent_crt - nb_indent != 1) printf("Alerte: indentation illegale, ligne %d, colonne %d\n", nb_lignes, nb_col);
						//nb_indent = nb_indent_crt;
						nb_indent ++; 
					    printf("INDENT\n"); 
						// printf("%s", yytext); 
						return indent;
					}
					
				}


"int" 		{
				printf("mot cle reconnu: %s\n", yytext);
				rechercher(yytext, "mc_int", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_int;
			}
"float" 	{
				printf("mot cle reconnu: %s\n", yytext);
				rechercher(yytext, "mc_float", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_float;
			}
"char" 		{
				printf("mot cle reconnu: %s\n", yytext);
				rechercher(yytext, "mc_char", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_char;
			}
"bool" 		{
				printf("mot cle reconnu: %s\n", yytext);
				rechercher(yytext, "mc_bool", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_bool;
			}
"if" 		{
				printf("mot cle reconnu: %s\n", yytext);
				rechercher(yytext, "mc_if", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_if;
			}
"else" 		{
				printf("mot cle reconnu: %s\n", yytext);
				rechercher(yytext, "mc_else", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_else;
			}
"for" 		{
				printf("mot cle reconnu: %s\n", yytext);
				rechercher(yytext, "mc_for", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_for;
			}
"in" 		{
				printf("mot cle reconnu: %s\n", yytext);
				rechercher(yytext, "mc_in", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_in;
			}
"range" 	{
				printf("mot cle reconnu: %s\n", yytext);
				rechercher(yytext, "mc_range", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_range;
			}
"while" 	{
				printf("mot cle reconnu: %s\n", yytext);
				rechercher(yytext, "mc_while", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_while;
			}
"=" 		{
				printf("operateur reconnu: %s\n", yytext);
				rechercher(yytext, "op aff", 0, 0, 2); 
				nb_col += yyleng; 
				return op_aff;
			}
">" 		{
				printf("operateur reconnu: %s\n", yytext);
				rechercher(yytext, "op sup", 0, 0, 2); 
				nb_col += yyleng; 
				return op_sup;
			}
">=" 		{
				printf("operateur reconnu: %s\n", yytext);
				rechercher(yytext, "op sup ou eg", 0, 0, 2); 
				nb_col += yyleng; 
				return op_sup_eg;
			}
"==" 		{
				printf("operateur reconnu: %s\n", yytext);
				rechercher(yytext, "op eg", 0, 0, 2); 
				nb_col += yyleng; 
				return op_eg;
			}
"!=" 		{
				printf("operateur reconnu: %s\n", yytext);
				rechercher(yytext, "op diff", 0, 0, 2);
				nb_col += yyleng; 
				return op_diff;
			}
"<=" 		{
				printf("operateur reconnu: %s\n", yytext);
				rechercher(yytext, "op inf ou eg", 0, 0, 2); 
				nb_col += yyleng; 
				return op_inf_eg;
			}
"<" 		{
				printf("operateur reconnu: %s\n", yytext);
				rechercher(yytext, "op inf", 0, 0, 2); 
				nb_col += yyleng; 
				return op_inf;
			}
"+" 		{
				printf("operateur reconnu: %s\n", yytext);
				rechercher(yytext, "op add", 0, 0, 2); 
				nb_col += yyleng; 
				return op_add;
			}
"-" 		{
				printf("operateur reconnu: %s\n", yytext);
				rechercher(yytext, "op sous", 0, 0, 2); 
				nb_col += yyleng; 
				return op_sous;
			}
"*" 		{
				printf("operateur reconnu: %s\n", yytext);
				rechercher(yytext, "op mult", 0, 0, 2); 
				nb_col += yyleng;
				return op_mul;
			}
"/" 		{	
				printf("operateur reconnu: %s\n", yytext);
				rechercher(yytext, "op div", 0, 0, 2); 
				nb_col += yyleng; 
				return op_div;
			}
"and" 		{
				printf("operateur reconnu: %s\n", yytext);
				rechercher(yytext, "op and", 0, 0, 2); 
				nb_col += yyleng; 
				return op_and;
			}
"or" 		{
				printf("operateur reconnu: %s\n", yytext);
				rechercher(yytext, "op or", 0, 0, 2); 
				nb_col += yyleng; 
				return op_or;
			}
"not" 		{
				printf("operateur reconnu: %s\n", yytext);
				rechercher(yytext, "op not", 0, 0, 2); 
				nb_col += yyleng; 
				return op_not;
			}
"(" 		{	
				printf("symbole reconnu: %s\n", yytext);
				rechercher(yytext, "par ouv", 0, 0, 2); 
				nb_col += yyleng; 
				return po;
			}
")" 		{
				printf("symbole reconnu: %s\n", yytext);
				rechercher(yytext, "par ferm", 0, 0, 2); 
				nb_col += yyleng; 
				return pf;
			}
"," 		{
				printf("symbole reconnu: %s\n", yytext);
				rechercher(yytext, "virg", 0, 0, 2); 
				nb_col += yyleng; 
				return virg;
			}
":" 		{
				printf("symbole reconnu: %s\n", yytext);
				rechercher(yytext, "deux points", 0, 0, 2); 
				nb_col += yyleng; 
				return deux_points;
			}
"[" 		{
				printf("symbole reconnu: %s\n", yytext);
				rechercher(yytext, "croch ouv", 0, 0, 2); 
				nb_col += yyleng; 
				return co;
			}
"]" 		{
				printf("symbole reconnu: %s\n", yytext);
				rechercher(yytext, "croch ferm", 0, 0, 2); 
				nb_col += yyleng; 
				return cf;
			}
{cst_char} 	{	
				printf("constante reconnue: %s\n", yytext);
				yylval.str = strdup(yytext); 
				rechercher(yytext, "cst_char", "char", 0, 0);
				nb_col += yyleng; 
				return cst_char;
			}
"true" 		{
				printf("constante reconnue: %s\n", yytext);
				nb_col += yyleng;
				yylval.str = strdup(yytext);
				rechercher(yytext, "cst_bool", "bool", 1, 0); 
				return cst_bool;
			}
"false" 	{
				printf("constante reconnue: %s\n", yytext);
				nb_col += yyleng;
				yylval.str = strdup(yytext);
				rechercher(yytext, "cst_bool", "bool", 0, 0); 
				return cst_bool;
			}
{unsigned_cst_float} {
						printf("constante reconnue: %s\n", yytext);
						nb_col += yyleng;
						if(atof(yytext) > 32767 || atof(yytext) < -32768)
						{
							printf("Erreur lexicale, ligne %d, colonne %d, %s\n", nb_lignes, nb_col, yytext);
						}
						else
						{
							yylval.str = strdup(yytext);
							rechercher(yytext, "cst_float", "float", atof(yytext), 0);  
							return unsigned_cst_float;
						}
					}
{signed_cst_float}  {
						printf("constante reconnue: %s\n", yytext);
						nb_col += yyleng;
						if(atof(yytext) > 32767 || atof(yytext) < -32768)
						{
							printf("Erreur lexicale, ligne %d, colonne %d, %s\n", nb_lignes, nb_col, yytext);
						}
						else
						{
							yylval.str = strdup(yytext);
							rechercher(yytext, "cst_float", "", atof(yytext), 0); 
							return signed_cst_float;
						}
					}
{signed_cst_int}	{
						printf("constante reconnue: %s\n", yytext);
						nb_col += yyleng;
						if(atoi(yytext) > 32767 || atoi(yytext) < -32768)
						{
							printf("Erreur lexicale, ligne %d, colonne %d, %s\n", nb_lignes, nb_col, yytext);
						}
						else
						{
							yylval.str = strdup(yytext);
							rechercher(yytext, "cst_int", "", atoi(yytext), 0);
							return signed_cst_int;
						}	
					}
{unsigned_cst_int} 	{
						printf("constante reconnue: %s\n", yytext);
						nb_col += yyleng;
						if(atoi(yytext) > 32767 || atoi(yytext) < -32768)
						{
							printf("Erreur lexicale, ligne %d, colonne %d, %s\n", nb_lignes, nb_col, yytext);
						}
						else
						{
							yylval.str = strdup(yytext);
							rechercher(yytext, "cst_int", "int", atoi(yytext), 0);
							return unsigned_cst_int;
						}
					}
{cmnt} 		{
				printf("commentaire: %s\n", yytext);
				nb_col += yyleng; 
				return cmnt;
			}
{idf} 		{
				printf("idf reconnu: %s\n", yytext);
				nb_col += yyleng; 
				if(yyleng>8)
				{
					printf("Erreur lexicale, ligne %d, colonne %d, %s\n", nb_lignes, nb_col, yytext);
				}
                else
				{
					yylval.str = strdup(yytext);
					rechercher(yytext, "idf", "", 0, 0);
					return idf;
				}
			}
^[ ]*\n		{
				// ignorer les lignes vides
				nb_col += yyleng;
				nb_lignes++; 
				nb_col = 1;
			}
[ ] 		{
				nb_col += yyleng;
			}
\n 			{
				nb_lignes++; 
				nb_col = 1; 
				return eol;
			}
. 			{
				printf("Erreur lexicale, ligne %d, colonne %d, %s\n", nb_lignes, nb_col, yytext); 
				nb_col += yyleng;
			}
<<EOF>>   	{
				if(nb_indent > 0) return dedent;
				return;
			}
%%
