%{
	#include "projet.tab.h"
	#include "TS.h"
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
cst ([1-9]{chiffre}*|0)
cst_bool (true|false)
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
						//printf("%s", yytext); 
						return indent;
					}
					//if(nb_indent_crt == nb_indent){return;}
	
					//printf("\n%d\n\n", nb_indent);
				}


"int" 		{
				rechercher(yytext, "mc_int", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_int;
			}
"float" 	{
				rechercher(yytext, "mc_float", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_float;
			}
"char" 		{
				rechercher(yytext, "mc_char", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_char;
			}
"bool" 		{
				rechercher(yytext, "mc_bool", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_bool;
			}
"if" 		{
				rechercher(yytext, "mc_if", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_if;
			}
"else" 		{
				rechercher(yytext, "mc_else", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_else;
			}
"for" 		{
				rechercher(yytext, "mc_for", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_for;
			}
"in" 		{
				rechercher(yytext, "mc_in", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_in;
			}
"range" 	{
				rechercher(yytext, "mc_range", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_range;
			}
"while" 	{
				rechercher(yytext, "mc_while", 0, 0, 1); 
				nb_col += yyleng; 
				return mc_while;
			}
"=" 		{
				rechercher(yytext, "op aff", 0, 0, 2); 
				nb_col += yyleng; 
				return op_aff;
			}
">" 		{
				rechercher(yytext, "op sup", 0, 0, 2); 
				nb_col += yyleng; 
				return op_sup;
			}
">=" 		{
				rechercher(yytext, "op sup ou eg", 0, 0, 2); 
				nb_col += yyleng; 
				return op_sup_eg;
			}
"==" 		{
				rechercher(yytext, "op eg", 0, 0, 2); 
				nb_col += yyleng; 
				return op_eg;
			}
"!=" 		{
				rechercher(yytext, "op diff", 0, 0, 2);
				nb_col += yyleng; 
				return op_diff;
			}
"<=" 		{
				rechercher(yytext, "op inf ou eg", 0, 0, 2); 
				nb_col += yyleng; 
				return op_inf_eg;
			}
"<" 		{
				rechercher(yytext, "op inf", 0, 0, 2); 
				nb_col += yyleng; 
				return op_inf;
			}
"+" 		{
				rechercher(yytext, "op add", 0, 0, 2); 
				nb_col += yyleng; 
				return op_add;
			}
"-" 		{
				rechercher(yytext, "op sous", 0, 0, 2); 
				nb_col += yyleng; 
				return op_sous;
			}
"*" 		{
				rechercher(yytext, "op mult", 0, 0, 2); 
				nb_col += yyleng;
				return op_mul;
			}
"/" 		{	
				rechercher(yytext, "op div", 0, 0, 2); 
				nb_col += yyleng; 
				return op_div;
			}
"and" 		{
				rechercher(yytext, "op and", 0, 0, 2); 
				nb_col += yyleng; 
				return op_and;
			}
"or" 		{
				rechercher(yytext, "op or", 0, 0, 2); 
				nb_col += yyleng; 
				return op_or;
			}
"not" 		{
				rechercher(yytext, "op not", 0, 0, 2); 
				nb_col += yyleng; 
				return op_not;
			}
"(" 		{	
				rechercher(yytext, "par ouv", 0, 0, 2); 
				nb_col += yyleng; 
				return po;
			}
")" 		{
				rechercher(yytext, "par ferm", 0, 0, 2); 
				nb_col += yyleng; 
				return pf;
			}
"," 		{
				rechercher(yytext, "virg", 0, 0, 2); 
				nb_col += yyleng; 
				return virg;
			}
":" 		{
				rechercher(yytext, "deux points", 0, 0, 2); 
				nb_col += yyleng; 
				return deux_points;
			}
"[" 		{
				rechercher(yytext, "croch ouv", 0, 0, 2); 
				nb_col += yyleng; 
				return co;
			}
"]" 		{
				rechercher(yytext, "croch ferm", 0, 0, 2); 
				nb_col += yyleng; 
				return cf;
			}
{cst_char} 	{ 	rechercher(yytext, "cst_char", "char", 0, 0);
				nb_col += yyleng; 
				return cst_char;
			}
{unsigned_cst_float} {
						nb_col += yyleng;
						//yylval.reel = atof(yytext);
						yylval.str = strdup(yytext);
						rechercher(yytext, "cst_float", "float", atof(yytext), 0);  
						return unsigned_cst_float;
					}
{signed_cst_float}  {
						nb_col += yyleng;
						//yylval.reel = atof(yytext);
						yylval.str = strdup(yytext);
						rechercher(yytext, "cst_float", "", atof(yytext), 0); 
						return signed_cst_float;
					}
{signed_cst_int}	{
						nb_col += yyleng;
						//yylval.entier = atoi(yytext); 
						yylval.str = strdup(yytext);
						rechercher(yytext, "cst_int", "", atoi(yytext), 0);
						return signed_cst_int;
					}
{unsigned_cst_int} 	{
						nb_col += yyleng;
						//yylval.entier = atoi(yytext);
						yylval.str = strdup(yytext);
						rechercher(yytext, "cst_int", "int", atoi(yytext), 0);
						return unsigned_cst_int;
					}
{cst_bool} 	{
				nb_col += yyleng;
				yylval.str = strdup(yytext);
				rechercher(yytext, "cst_bool", "cst", 0, 0); 
				return cst_bool;
			}
{cmnt} 		{
				nb_col += yyleng; 
				return cmnt;
			}
{idf} 		{
				yylval.str = strdup(yytext);
				nb_col += yyleng; 
				if(yyleng>8)
				{
					printf("Erreur lexicale, ligne %d, colonne %d, %s\n", nb_lignes, nb_col, yytext);
				}
                else
				{
					rechercher(yytext, "idf", "", 0, 0);
					return idf;
				}
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
%%
